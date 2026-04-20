import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/cycle_data/cycle_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_cycle_data.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  group('FakeCycleData (CycleData interface verification)', () {
    late FakeCycleData fakeCycleData;

    setUp(() {
      fakeCycleData = FakeCycleData();
    });

    test('يُرجع الاستجابة المُعدّة لـ getCycles', () async {
      fakeCycleData.when('getCycles', Right<StatusRequest, Map<String, dynamic>>({
        'status': 'success',
        'data': {
          'cycles': [sampleCycleJson],
        },
      }));

      final result = await fakeCycleData.getCycles(token: 'fake-token');

      expect(result.isRight(), isTrue);
    });

    test('يُرجع الاستجابة المُعدّة لـ createCycle', () async {
      fakeCycleData.when('createCycle', Right<StatusRequest, Map<String, dynamic>>({
        'status': 'success',
        'data': {'cycle_id': 1},
      }));

      final result = await fakeCycleData.createCycle(
        token: 'fake-token',
        name: 'دورة جديدة',
        chickCount: 500,
        space: 100.0,
        startDateRaw: '2026-01-01',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (data) => expect(data['data']['cycle_id'], 1),
      );
    });

    test('يُرجع serverFailure كقيمة افتراضية عند method غير مسجّل', () async {
      final result = await fakeCycleData.getCycles(token: 'fake-token');

      expect(result.isLeft(), isTrue);
      result.fold(
        (status) => expect(status, StatusRequest.serverFailure),
        (_) => fail('Expected Left'),
      );
    });

    test('يُرجع offlineFailure عند تحضيره', () async {
      fakeCycleData.when('getCycles', const Left(StatusRequest.offlineFailure));

      final result = await fakeCycleData.getCycles(token: 'fake-token');

      expect(result.isLeft(), isTrue);
      result.fold(
        (status) => expect(status, StatusRequest.offlineFailure),
        (_) => fail('Expected Left'),
      );
    });

    test('يُرجع الاستجابة المُعدّة لـ getCycleDetails', () async {
      fakeCycleData.when('getCycleDetails', Right<StatusRequest, Map<String, dynamic>>({
        'status': 'success',
        'data': <String, dynamic>{
          'cycle': sampleCycleJson,
          'data': <dynamic>[],
          'expenses': <dynamic>[],
        },
      }));

      final result = await fakeCycleData.getCycleDetails(
        token: 'fake-token',
        cycleId: 1,
      );

      expect(result.isRight(), isTrue);
    });

    test('implements CycleData — يمكن استخدامه كبديل آمن', () {
      expect(fakeCycleData, isA<CycleData>());
    });
  });
}
