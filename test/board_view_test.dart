import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/data/worlds.dart';
import 'package:mergelings/l10n/app_localizations.dart';
import 'package:mergelings/models/game_state.dart';
import 'package:mergelings/ui/widgets/board_view.dart';

Widget _harness(BoardState board, World world, void Function(int, int) onMove) {
  return MaterialApp(
    localizationsDelegates: L.localizationsDelegates,
    supportedLocales: L.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 500,
        child: BoardView(
          board: board,
          world: world,
          mergedCell: null,
          accessoryOf: (_) => null,
          nameOf: (_) => 'friend',
          onMove: onMove,
          onInspect: (_) {},
          onOpenMystery: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a tile dragged onto a neighbour reports the move', (
    WidgetTester tester,
  ) async {
    final World world = worldById('day');
    final BoardState board = BoardState.empty(world.id);
    board.set(0, BoardTile(id: 1, tier: 1));
    board.set(1, BoardTile(id: 2, tier: 1));
    board.set(2, BoardTile(id: 3, tier: 1, mystery: true));

    int? movedFrom;
    int? movedTo;

    await tester.pumpWidget(
      _harness(board, world, (int from, int to) {
        movedFrom = from;
        movedTo = to;
      }),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final Size cell = tester.getSize(find.byType(DragTarget<int>).first);
    final Offset from = tester.getCenter(find.byType(DragTarget<int>).first);

    final TestGesture gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveTo(from + Offset(cell.width, 0));
    await tester.pump(const Duration(milliseconds: 80));

    // The friend that was picked up leaves its perch empty while a copy of it
    // rides in the overlay under the thumb. This is `childWhenDragging` doing
    // the work on its own — the board keeps no drag state of its own, because
    // tracking it there cost a rebuild of every cell on each drag start.
    expect(find.byKey(const ValueKey<int>(1)), findsNothing);
    expect(find.byKey(const ValueKey<int>(2)), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 200));

    expect(movedFrom, 0);
    expect(movedTo, 1);
  });

  testWidgets('the meadow does not share one repaint layer', (
    WidgetTester tester,
  ) async {
    final World world = worldById('day');
    final BoardState board = BoardState.empty(world.id);
    board.set(0, BoardTile(id: 1, tier: 1));

    await tester.pumpWidget(_harness(board, world, (_, _) {}));
    await tester.pump(const Duration(milliseconds: 100));

    // A perch and the creature standing on it each hold their own layer, so a
    // breathing friend cannot drag the scenery — or the rest of the meadow —
    // through a repaint with it.
    expect(
      find.byType(RepaintBoundary),
      findsAtLeast(board.rows * 2),
      reason: 'every perch should be behind its own repaint boundary',
    );
  });
}
