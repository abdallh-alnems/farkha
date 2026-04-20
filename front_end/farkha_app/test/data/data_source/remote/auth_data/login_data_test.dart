import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/auth_data/login_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_login_data.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  group('FakeLoginData (LoginData interface verification)', () {
    late FakeLoginData fakeLoginData;

    setUp(() {
      fakeLoginData = FakeLoginData();
    });

    test('يُرجع الاستجابة المُعدّة عند تسجيل الدخول الناجح', () async {
      fakeLoginData.loginResponse = const Right(sampleLoginSuccessJson);

      final result = await fakeLoginData.login('fake-token');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (data) => expect(data['status'], 'success'),
      );
    });

    test('يُرجع serverFailure كقيمة افتراضية عند عدم تحضير استجابة', () async {
      final result = await fakeLoginData.login('fake-token');

      expect(result.isLeft(), isTrue);
      result.fold(
        (status) => expect(status, StatusRequest.serverFailure),
        (_) => fail('Expected Left'),
      );
    });

    test('يُرجع offlineFailure عند تحضيره', () async {
      fakeLoginData.loginResponse = const Left(StatusRequest.offlineFailure);

      final result = await fakeLoginData.login('fake-token');

      expect(result.isLeft(), isTrue);
      result.fold(
        (status) => expect(status, StatusRequest.offlineFailure),
        (_) => fail('Expected Left'),
      );
    });

    test('implements LoginData — يمكن استخدامه كبديل آمن', () {
      expect(fakeLoginData, isA<LoginData>());
    });
  });
}
