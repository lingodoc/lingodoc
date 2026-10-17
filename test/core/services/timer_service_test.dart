import 'package:flutter_test/flutter_test.dart';
import 'package:lingodoc/core/services/timer_service.dart';

void main() {
  final service = TimerService();

  tearDown(() {
    service.cancelAll();
  });

  group('TimerService', () {
    test('register makes timer isRegistered', () {
      service.register('t1', const Duration(seconds: 10), () {});
      expect(service.isRegistered('t1'), isTrue);
    });

    test('register stores the interval', () {
      service.register('t2', const Duration(milliseconds: 500), () {});
      expect(
        service.getInterval('t2'),
        equals(const Duration(milliseconds: 500)),
      );
    });

    test('registering the same ID twice replaces the timer', () {
      service.register('dup', const Duration(seconds: 5), () {});
      service.register('dup', const Duration(seconds: 99), () {});
      expect(service.getRegisteredIds().where((id) => id == 'dup').length, 1);
      expect(service.getInterval('dup'), equals(const Duration(seconds: 99)));
    });

    test('cancel existing timer returns true and removes it', () {
      service.register('x', const Duration(seconds: 1), () {});
      final result = service.cancel('x');
      expect(result, isTrue);
      expect(service.isRegistered('x'), isFalse);
    });

    test('cancel non-existent timer returns false', () {
      expect(service.cancel('ghost'), isFalse);
    });

    test('cancelAll clears all registrations', () {
      service.register('a', const Duration(seconds: 1), () {});
      service.register('b', const Duration(seconds: 2), () {});
      service.cancelAll();
      expect(service.getRegisteredIds(), isEmpty);
    });

    test('getDebugInfo with no timers contains expected text', () {
      final info = service.getDebugInfo();
      expect(info, contains('No timers registered'));
    });

    test('getDebugInfo with a registered timer contains the ID', () {
      service.register('probe', const Duration(seconds: 3), () {});
      final info = service.getDebugInfo();
      expect(info, contains('probe'));
      expect(info, contains('3000'));
    });
  });
}
