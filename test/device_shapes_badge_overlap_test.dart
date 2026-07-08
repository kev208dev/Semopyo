// Regression test for the badge-overlap bug fixed in lib/device_shapes.dart.
// Written as a throwaway verification check for that fix; kept afterward
// because it caught a real bug (WatchShape) that the original fix
// instructions didn't anticipate -- see the review-response report for
// details. Repo has no broader test suite/convention yet, so this stands
// alone under test/.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semopyo/device_shapes.dart';
import 'package:semopyo/device_sim_data.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, DeviceCategoryDef def, double width) async {
    final build = DeviceBuild(def);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            // Loose/bounded width constraint from a Column, matching the
            // real builder page layout that exposed the shrink-wrap bug.
            child: Column(
              children: [
                deviceShapeFor(build, false, (_) {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool rectsOverlap(Rect a, Rect b) => a.overlaps(b);

  testWidgets('Phone badges do not overlap at width=360', (tester) async {
    await pumpAt(tester, phoneDef, 360);

    final badgeFinder = find.byType(SlotBadge);
    expect(badgeFinder, findsNWidgets(4)); // chipset, ram, storage, battery

    final rects = <Rect>[];
    for (var i = 0; i < 4; i++) {
      final el = tester.widgetList(badgeFinder).elementAt(i);
      final topLeft = tester.getTopLeft(badgeFinder.at(i));
      final size = tester.getSize(badgeFinder.at(i));
      rects.add(topLeft & size);
      // ignore: avoid_print
      print('badge $i (${(el as SlotBadge).slot.id}): $topLeft size=$size');
    }

    for (var i = 0; i < rects.length; i++) {
      for (var j = i + 1; j < rects.length; j++) {
        expect(
          rectsOverlap(rects[i], rects[j]),
          isFalse,
          reason: 'Badges $i and $j overlap: ${rects[i]} vs ${rects[j]}',
        );
      }
    }
  });

  testWidgets('Tablet badges do not overlap at width=360', (tester) async {
    await pumpAt(tester, tabletDef, 360);

    final badgeFinder = find.byType(SlotBadge);
    final rects = <Rect>[];
    for (var i = 0; i < tester.widgetList(badgeFinder).length; i++) {
      final topLeft = tester.getTopLeft(badgeFinder.at(i));
      final size = tester.getSize(badgeFinder.at(i));
      rects.add(topLeft & size);
    }
    for (var i = 0; i < rects.length; i++) {
      for (var j = i + 1; j < rects.length; j++) {
        expect(rectsOverlap(rects[i], rects[j]), isFalse,
            reason: 'Badges $i and $j overlap: ${rects[i]} vs ${rects[j]}');
      }
    }
  });

  testWidgets('Laptop badges do not overlap at width=360', (tester) async {
    await pumpAt(tester, laptopDef, 360);

    final badgeFinder = find.byType(SlotBadge);
    final rects = <Rect>[];
    for (var i = 0; i < tester.widgetList(badgeFinder).length; i++) {
      final topLeft = tester.getTopLeft(badgeFinder.at(i));
      final size = tester.getSize(badgeFinder.at(i));
      rects.add(topLeft & size);
    }
    for (var i = 0; i < rects.length; i++) {
      for (var j = i + 1; j < rects.length; j++) {
        expect(rectsOverlap(rects[i], rects[j]), isFalse,
            reason: 'Badges $i and $j overlap: ${rects[i]} vs ${rects[j]}');
      }
    }
  });

  // Control checks: reviewer claimed these two are unaffected. Verify that claim
  // rather than take it on faith.
  testWidgets('Desktop badges do not overlap at width=360 (control)', (tester) async {
    await pumpAt(tester, desktopDef, 360);
    final badgeFinder = find.byType(SlotBadge);
    final rects = <Rect>[];
    for (var i = 0; i < tester.widgetList(badgeFinder).length; i++) {
      final topLeft = tester.getTopLeft(badgeFinder.at(i));
      final size = tester.getSize(badgeFinder.at(i));
      rects.add(topLeft & size);
    }
    for (var i = 0; i < rects.length; i++) {
      for (var j = i + 1; j < rects.length; j++) {
        expect(rectsOverlap(rects[i], rects[j]), isFalse,
            reason: 'Badges $i and $j overlap: ${rects[i]} vs ${rects[j]}');
      }
    }
  });

  testWidgets('Watch badges do not overlap at width=360 (control)', (tester) async {
    await pumpAt(tester, watchDef, 360);
    final badgeFinder = find.byType(SlotBadge);
    final rects = <Rect>[];
    for (var i = 0; i < tester.widgetList(badgeFinder).length; i++) {
      final topLeft = tester.getTopLeft(badgeFinder.at(i));
      final size = tester.getSize(badgeFinder.at(i));
      rects.add(topLeft & size);
      // ignore: avoid_print
      print('watch badge $i: $topLeft size=$size');
    }
    for (var i = 0; i < rects.length; i++) {
      for (var j = i + 1; j < rects.length; j++) {
        expect(rectsOverlap(rects[i], rects[j]), isFalse,
            reason: 'Badges $i and $j overlap: ${rects[i]} vs ${rects[j]}');
      }
    }
  });
}
