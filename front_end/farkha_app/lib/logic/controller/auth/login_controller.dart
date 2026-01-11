import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/services/initialization.dart';
import '../../../data/data_source/remote/auth_data/login_data.dart';
import '../cycle_controller.dart';

class LoginController extends GetxController {
  late final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final LoginData _loginData;

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _auth = FirebaseAuth.instance;
    _loginData = LoginData();
    // قراءة حالة تسجيل الدخول الحالية
    if (Get.isRegistered<MyServices>()) {
      final myServices = Get.find<MyServices>();
      isLoggedIn.value = myServices.getStorage.read<bool>('is_logged_in') ?? false;
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    // محاولة متعددة للحصول على context صالح
    void tryShow(int attempt) {
      if (attempt > 5) {
        // إذا فشلت جميع المحاولات، استخدم Get.snackbar كبديل
        Get.snackbar(
          isError ? 'خطأ' : 'نجاح',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor:
              isError
                  ? Colors.red.withValues(alpha: 0.9)
                  : Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 3),
        );
        return;
      }

      Future.delayed(Duration(milliseconds: 300 + (attempt * 200)), () {
        final BuildContext? currentContext =
            Get.key.currentContext ?? Get.context;
        if (currentContext != null && currentContext.mounted) {
          final scaffoldMessenger = ScaffoldMessenger.maybeOf(currentContext);
          if (scaffoldMessenger != null) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.check_circle,
                      color: Colors.white,
                      size: 21,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: isError ? Colors.red : Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            tryShow(attempt + 1);
          }
        } else {
          tryShow(attempt + 1);
        }
      });
    }

    tryShow(0);
  }

  Future<void> _initializeGoogleSignIn() async {
    if (!_isInitialized) {
      try {
        await _googleSignIn.initialize(
          serverClientId:
              '159521160544-a50bd58sqojqi4gu07ejinjab17asct9.apps.googleusercontent.com',
        );
        _isInitialized = true;
      } catch (e) {
        debugPrint('Google Sign In initialization error: $e');
      }
    }
  }

  Future<void> onGoogleSignIn() async {
    try {
      isLoading.value = true;
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final String? idToken = googleUser.authentication.idToken;
      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final String? accessToken = authorization?.accessToken;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        isLoading.value = false;
        _showSnackbar('فشل تسجيل الدخول', isError: true);
        return;
      }

      final String? firebaseToken = await userCredential.user!.getIdToken();
      if (firebaseToken == null) {
        isLoading.value = false;
        _showSnackbar('فشل الحصول على رمز الدخول', isError: true);
        return;
      }

      final bool success = await _sendTokenToBackend(firebaseToken);
      isLoading.value = false;

      if (success) {
        _showSnackbar('تم تسجيل الدخول بنجاح');
        
        // جلب الدورات من API بعد تسجيل الدخول الناجح
        if (Get.isRegistered<CycleController>()) {
          final cycleController = Get.find<CycleController>();
          await cycleController.fetchCyclesFromServer();
        }
        
        // انتظار وقت كافٍ لعرض الرسالة قبل إغلاق الصفحة
        await Future.delayed(const Duration(milliseconds: 2500));
        Get.back();
      } else {
        _showSnackbar('فشل الاتصال بالخادم', isError: true);
      }
    } on GoogleSignInException catch (e) {
      isLoading.value = false;
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      _showSnackbar(_getGoogleErrorMessage(e.code), isError: true);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      _showSnackbar(_getFirebaseErrorMessage(e.code), isError: true);
    } catch (e) {
      isLoading.value = false;
      _showSnackbar('حدث خطأ أثناء تسجيل الدخول', isError: true);
    }
  }

  Future<bool> _sendTokenToBackend(String token) async {
    try {
      final response = await _loginData.login(token);

      return response.fold((_) => false, (result) {
        final data = result as Map<String, dynamic>;
        final isSuccess =
            data['success'] == true || data['status'] == 'success';

        if (isSuccess && data['user'] != null) {
          final userData = data['user'] as Map<String, dynamic>;
          final myServices = Get.find<MyServices>();
          myServices.getStorage.write('user_name', userData['name']);
          myServices.getStorage.write('is_logged_in', true);
          isLoggedIn.value = true; // تحديث observable
          return true;
        }

        return false;
      });
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Google and Firebase
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear all user data from GetStorage
      final myServices = Get.find<MyServices>();
      myServices.getStorage.remove('user_name');
      myServices.getStorage.remove('user_phone');
      myServices.getStorage.write('is_logged_in', false);
      isLoggedIn.value = false; // تحديث observable

      // Show success message
      _showSnackbar('تم تسجيل الخروج بنجاح');
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تسجيل الخروج', isError: true);
    }
  }

  String _getGoogleErrorMessage(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.canceled:
        return 'تم إلغاء تسجيل الدخول';
      case GoogleSignInExceptionCode.interrupted:
        return 'تم مقاطعة عملية تسجيل الدخول';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'واجهة تسجيل الدخول غير متاحة';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'خطأ في إعدادات التطبيق';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'خطأ في إعدادات Google';
      case GoogleSignInExceptionCode.userMismatch:
        return 'عدم تطابق المستخدم';
      case GoogleSignInExceptionCode.unknownError:
        return 'حدث خطأ غير متوقع';
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'يوجد حساب مسجل بهذا البريد بطريقة أخرى';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صالحة';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بـ Google غير مفعل';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'user-not-found':
        return 'لم يتم العثور على المستخدم';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
