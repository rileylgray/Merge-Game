import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/ads_service.dart';
import '../../state/game_controller.dart';
import '../dialogs.dart';
import '../widgets/banner_ad_slot.dart';
import 'collection_screen.dart';
import 'meadow_screen.dart';
import 'meadows_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

/// An [IndexedStack] that fades on the way in when the tab changes.
///
/// The stack itself is kept — every screen holds state worth preserving, like
/// the collection's scroll position and the meadow's scroll offset — so the
/// transition is a fade *up* on the arriving screen rather than a cross-fade
/// between two live trees.
///
/// Keeping them all alive is not the same as keeping them all running. An
/// [IndexedStack] paints one child and lays out the rest, but every ticker in
/// those hidden trees keeps firing: four meadows' worth of idling creatures,
/// rocking mystery baskets and drifting motes, animating sixty times a second
/// against a screen nobody can see. Each child gets a [TickerMode] pinned to
/// whether it is the visible one, which silences all of that — and, through
/// [TickBuilder], stops the hidden screens rebuilding on the income tick too.
class _FadeThrough extends StatefulWidget {
  const _FadeThrough({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeThrough> createState() => _FadeThroughState();
}

class _FadeThroughState extends State<_FadeThrough>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  /// Never all the way to transparent: a tab that blinks out feels slower than
  /// one that simply arrives.
  late final Animation<double> _opacity = Tween<double>(
    begin: .35,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void didUpdateWidget(covariant _FadeThrough old) {
    super.didUpdateWidget(old);
    if (widget.index != old.index) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: IndexedStack(
        index: widget.index,
        children: <Widget>[
          for (int i = 0; i < widget.children.length; i++)
            TickerMode(enabled: i == widget.index, child: widget.children[i]),
        ],
      ),
    );
  }
}

/// Root navigation, plus the one place that owns app-wide interruptions:
/// discovery fanfare, offline earnings and interstitials.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  bool _showingDialog = false;
  GameController? _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainEvents());
  }

  // Queued celebrations are the shell's only interest in the controller, and
  // watching it for them meant rebuilding this whole tree — and scheduling a
  // drain — on every notification. A listener asks the same question without
  // the rebuild.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GameController game = context.read<GameController>();
    if (identical(game, _game)) return;
    _game?.removeListener(_onGameChanged);
    _game = game..addListener(_onGameChanged);
  }

  void _onGameChanged() {
    final GameController? game = _game;
    if (game == null) return;
    if (game.pendingDiscovery != null || game.pendingOffline != null) {
      unawaitedDrain();
    }
  }

  @override
  void dispose() {
    _game?.removeListener(_onGameChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final GameController game = context.read<GameController>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        game.onPaused();
      case AppLifecycleState.resumed:
        game.onResumed();
        _drainEvents();
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// Shows queued celebrations one at a time so they never stack.
  Future<void> _drainEvents() async {
    if (_showingDialog || !mounted) return;
    final GameController game = context.read<GameController>();
    final AdsService ads = context.read<AdsService>();

    final OfflineEarnings? offline = game.pendingOffline;
    if (offline != null) {
      _showingDialog = true;
      // The dialog watches the ad service itself, so the double offer can
      // light up while it is already on screen.
      ads.prewarm();
      final bool? doubled = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => OfflineDialog(
          hearts: offline.hearts,
          away: offline.away,
        ),
      );
      bool granted = false;
      if (doubled == true) granted = await ads.showRewarded();
      game.grantOffline(doubled: granted);
      _showingDialog = false;
      if (mounted) unawaitedDrain();
      return;
    }

    final DiscoveryEvent? discovery = game.pendingDiscovery;
    if (discovery != null) {
      _showingDialog = true;
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => DiscoveryDialog(
          spec: discovery.spec,
          name: game.nameOf(discovery.spec),
          gems: discovery.gems,
        ),
      );
      game.clearDiscovery();
      _showingDialog = false;
      if (mounted) unawaitedDrain();
    }
  }

  void unawaitedDrain() => WidgetsBinding.instance.addPostFrameCallback(
        (_) => _drainEvents(),
      );

  Future<void> _onTabSelected(int next) async {
    final int previous = _index;
    context.read<GameController>().playTap();
    setState(() => _index = next);

    // An interstitial on the way *back* to the meadow keeps ads out of the
    // core merge loop while still giving a natural break point.
    if (next == 0 && previous != 0) {
      await context.read<AdsService>().maybeShowInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final L l = L.of(context);

    return Scaffold(
      body: _FadeThrough(
        index: _index,
        children: <Widget>[
          const MeadowScreen(),
          const CollectionScreen(),
          const ShopScreen(),
          MeadowsScreen(onEnterMeadow: () => setState(() => _index = 0)),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const BannerAdSlot(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onTabSelected,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.grass_outlined),
                selectedIcon: const Icon(Icons.grass_rounded),
                label: l.navMeadow,
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book_rounded),
                label: l.navCollection,
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined),
                selectedIcon: const Icon(Icons.storefront_rounded),
                label: l.navShop,
              ),
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map_rounded),
                label: l.navMeadows,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: l.navSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
