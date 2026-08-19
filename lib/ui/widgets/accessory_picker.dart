import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../data/accessory.dart';
import '../../data/creature_spec.dart';
import '../../l10n/app_localizations.dart';
import '../../state/game_controller.dart';
import '../accessory_labels.dart';
import 'accessory_icon.dart';

/// Dresses one friend: a row of everything the player owns, plus a way to take
/// the current item off again.
///
/// Wearing is keyed to the species, so this changes every copy of that
/// creature at once — including the ones not on the board right now.
class AccessoryPicker extends StatelessWidget {
  const AccessoryPicker({super.key, required this.spec});

  final CreatureSpec spec;

  @override
  Widget build(BuildContext context) {
    final GameController game = context.watch<GameController>();
    final L l = L.of(context);
    final List<Accessory> owned = game.ownedAccessories;
    final AccessoryType? worn = game.accessoryFor(spec);

    if (owned.isEmpty) {
      return Text(
        l.accessoryEmptyHint,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: AppTheme.ink.withValues(alpha: .5),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l.accessoryTitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
            color: AppTheme.ink.withValues(alpha: .55),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: owned.length + 1,
            separatorBuilder: (BuildContext context, int i) =>
                const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int i) {
              if (i == 0) {
                return _Chip(
                  selected: worn == null,
                  label: l.accessoryNone,
                  onTap: () => game.wearAccessory(spec, null),
                  child: Icon(
                    Icons.not_interested_rounded,
                    color: AppTheme.ink.withValues(alpha: .35),
                  ),
                );
              }
              final AccessoryType type = owned[i - 1].type;
              return _Chip(
                selected: worn == type,
                label: accessoryName(l, type),
                onTap: () => game.wearAccessory(spec, type),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: AccessoryIcon(type),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          worn == null ? l.accessoryNone : accessoryName(l, worn),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? AppTheme.brand.withValues(alpha: .14)
            : Colors.black.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppTheme.brand
                    : Colors.black.withValues(alpha: .07),
                width: selected ? 2 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
