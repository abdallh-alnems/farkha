import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/headers.dart';

class SseService extends GetxService {
  Timer? _reconnectTimer;
  StreamController<Map<String, dynamic>>? _dataController;
  bool _isConnected = false;
  String? _currentUrl;

  Stream<Map<String, dynamic>> get dataStream {
    // إنشاء StreamController إذا لم يكن موجوداً
    if (_dataController == null || _dataController!.isClosed) {
      _dataController = StreamController<Map<String, dynamic>>.broadcast();
    }

    return _dataController!.stream;
  }

  bool get isConnected => _isConnected;

  /// بدء الاتصال بـ SSE
  Future<void> connect(String url) async {
    try {
      _currentUrl = url;

      // لا نحتاج لإنشاء StreamController جديد هنا لأنه يتم إنشاؤه في dataStream getter

      // استخدام POST مباشرة
      await _tryConnect(url, 'POST');
    } catch (e) {
      _isConnected = false;
      _reconnect();
    }
  }

  /// محاولة الاتصال بطريقة معينة
  Future<void> _tryConnect(String url, String method) async {
    // استخدام HTTP request مع stream للـ SSE
    final request = http.Request(method, Uri.parse(url));
    request.headers['Cache-Control'] = 'no-cache';
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Connection'] = 'keep-alive';
    request.headers['User-Agent'] = 'Flutter/1.0';
    request.headers['Pragma'] = 'no-cache';
    request.headers['Expires'] = '0';

    // إضافة رموز الأمان باستخدام نفس الطريقة مثل Crud
    final authHeaders = getMyHeaders();
    request.headers.addAll(authHeaders);

    final streamedResponse = await http.Client().send(request);

    if (streamedResponse.statusCode == 200) {
      _isConnected = true;

      // قراءة البيانات كـ stream مباشرة
      streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              // تجاهل الأسطر الفارغة والتعليقات
              if (line.isEmpty || line.startsWith(':')) {
                return;
              }

              // معالجة البيانات
              if (line.startsWith('data: ')) {
                final data = line.substring(6); // إزالة 'data: '
                if (data.isNotEmpty && data != '[DONE]') {
                  _handleSseData(data);
                }
              } else if (line.startsWith('event: ')) {
                // يمكن إضافة معالجة للـ events هنا
              } else if (line.startsWith('id: ')) {
                // يمكن إضافة معالجة للـ IDs هنا
              } else {
                // محاولة معالجة البيانات بدون prefix
                if (line.trim().isNotEmpty) {
                  try {
                    // محاولة تحليل JSON مباشرة
                    final jsonData = json.decode(line.trim());
                    if (jsonData is Map<String, dynamic>) {
                      if (_dataController != null &&
                          !_dataController!.isClosed) {
                        _dataController!.add(jsonData);
                      }
                    }
                  } catch (e) {
                    // محاولة معالجة البيانات كـ string عادي
                    final textData = {
                      'status': 'text',
                      'data': line.trim(),
                      'type': 'plain_text',
                    };
                    if (_dataController != null && !_dataController!.isClosed) {
                      _dataController!.add(textData);
                    }
                  }
                }
              }
            },
            onError: (error) {
              _isConnected = false;
              _reconnect();
            },
            onDone: () {
              _isConnected = false;

              // إذا كان لدينا بيانات، لا نحتاج لإعادة الاتصال
              if (_dataController?.hasListener == true) {
                // البيانات تم استلامها، الاتصال انغلق بشكل طبيعي
              } else {
                _reconnect();
              }
            },
          );
    } else {
      throw Exception('HTTP ${streamedResponse.statusCode}');
    }
  }

  /// معالجة البيانات الواردة من SSE
  void _handleSseData(String data) {
    try {
      final jsonData = json.decode(data);
      if (jsonData is Map<String, dynamic>) {
        if (_dataController != null && !_dataController!.isClosed) {
          _dataController!.add(jsonData);
        }
      }
    } catch (e) {
      // يمكن إضافة معالجة للأخطاء هنا إذا لزم الأمر
    }
  }

  /// إعادة الاتصال التلقائي
  void _reconnect() {
    if (!_isConnected && _currentUrl != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        connect(_currentUrl!);
      });
    }
  }

  /// إغلاق الاتصال
  void disconnect() {
    _isConnected = false;
    _reconnectTimer?.cancel();
    _dataController?.close();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
