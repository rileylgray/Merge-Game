import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergelings/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('dev.britannio.in_app_review');
  late int requests;

  setUp(() {
    requests = 0;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'isAvailable':
          return true;
        case 'requestReview':
          requests++;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('waits for a few discoveries, then asks once per session', () async {
    final ReviewService review = ReviewService.newSession();
    for (int found = 1; found < 8; found++) {
      await review.onDiscovery(discovered: found);
    }
    expect(requests, 0);

    await review.onDiscovery(discovered: 8);
    expect(requests, 1);

    await review.onDiscovery(discovered: 40);
    expect(requests, 1);
  });

  test('later asks are spaced out and stop after three', () async {
    await ReviewService.newSession().onDiscovery(discovered: 8);
    expect(requests, 1);

    ReviewService review = ReviewService.newSession();
    await review.onDiscovery(discovered: 22);
    expect(requests, 1);
    await review.onDiscovery(discovered: 23);
    expect(requests, 2);

    review = ReviewService.newSession();
    await review.onDiscovery(discovered: 52);
    expect(requests, 2);
    await review.onDiscovery(discovered: 53);
    expect(requests, 3);

    for (final int found in <int>[100, 150]) {
      await ReviewService.newSession().onDiscovery(discovered: found);
    }
    expect(requests, 3);
  });

  test('a store that cannot show the sheet does not use up an ask', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async => false);
    await ReviewService.newSession().onDiscovery(discovered: 8);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('review_asks'), isNull);
  });
}
