import 'package:farkha_app/core/services/analytics_service.dart';
import 'package:get/get.dart';

class FakeAnalyticsService extends GetxService implements AnalyticsService {
  final List<({String name, Map<String, Object?>? params})> events = [];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add((name: name, params: parameters));
  }

  @override
  Future<void> logToolPageView({required String toolName}) async {
    events.add((name: 'tool_page_view', params: {'tool_name': toolName}));
  }

  @override
  Future<AnalyticsService> init() async => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
