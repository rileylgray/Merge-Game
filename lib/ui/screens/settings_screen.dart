import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_config.dart';
import '../../core/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ads_service.dart';
import '../../state/game_controller.dart';

const Map<String, String> kLanguageNames = <String, String>{
  'en': 'English',
  'es': 'Español',
  'pt': 'Português',
  'fr': 'Français',
  'de': 'Deutsch',
};

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo info) {
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameController game = context.watch<GameController>();
    final AdsService ads = context.watch<AdsService>();
    final L l = L.of(context);

    return Scaffold(
      backgroundColor: AppTheme.parchment,
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l.settingsLanguage),
                  subtitle: Text(
                    game.state.localeCode == null
                        ? l.settingsSystemLanguage
                        : kLanguageNames[game.state.localeCode] ?? '',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pickLanguage(context, game),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: Text(l.settingsSound),
                  value: game.state.soundEnabled,
                  onChanged: game.setSound,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.music_note_rounded),
                  title: Text(l.settingsMusic),
                  value: game.state.musicEnabled,
                  onChanged: game.setMusic,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded),
                  title: Text(l.settingsHaptics),
                  value: game.state.hapticsEnabled,
                  onChanged: game.setHaptics,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: Text(l.settingsPrivacy),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => _open(AppConfig.privacyPolicyUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_rounded),
                  title: Text(l.settingsTerms),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => _open(AppConfig.termsUrl),
                ),
                // Only shown where the UMP SDK says a privacy entry point is
                // legally required (EEA, UK and similar).
                if (ads.privacyOptionsRequired) ...<Widget>[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.ads_click_rounded),
                    title: Text(l.settingsAdPrivacy),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: ads.showPrivacyOptions,
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_rounded),
                  title: Text(l.settingsRate),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => _open(AppConfig.storeUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restart_alt_rounded, color: Colors.red),
              title: Text(
                l.settingsReset,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmReset(context, game),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              _version.isEmpty ? '' : l.settingsVersion(_version),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.ink.withValues(alpha: .45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(url)),
        );
      }
    }
  }

  Future<void> _pickLanguage(BuildContext context, GameController game) async {
    final L l = L.of(context);
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) => SafeArea(
        child: RadioGroup<String>(
          groupValue: game.state.localeCode ?? '',
          onChanged: (String? v) => Navigator.of(context).pop(v ?? ''),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 12),
              Text(
                l.settingsLanguage,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                value: '',
                title: Text(l.settingsSystemLanguage),
              ),
              for (final MapEntry<String, String> e in kLanguageNames.entries)
                RadioListTile<String>(
                  value: e.key,
                  title: Text(e.value),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (choice != null) {
      await game.setLocale(choice.isEmpty ? null : choice);
    }
  }

  Future<void> _confirmReset(BuildContext context, GameController game) async {
    final L l = L.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l.settingsReset),
        content: Text(l.settingsResetBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.reset),
          ),
        ],
      ),
    );
    if (confirmed == true) await game.resetProgress();
  }
}
