import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/services/initialization.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/data_source/remote/auth_data/login_data.dart';
import '../cycle_controller.dart';
import '../tools_controller/favorite_tools_controller.dart';

class LoginController extends GetxController {
  LoginController({
    FirebaseAuth? auth,
    LoginData? loginData,
    GoogleSignIn? googleSignIn,
  })  : _authOverride = auth,
        _loginDataOverride = loginData,
        _googleSignInOverride = googleSignIn;

  final FirebaseAuth? _authOverride;
  final LoginData? _loginDataOverride;
  final GoogleSignIn? _googleSignInOverride;

  late final FirebaseAuth _auth;
  late final LoginData _loginData;
  late final GoogleSignIn _googleSignIn;

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _auth = _authOverride ?? FirebaseAuth.instance;
    _loginData = _loginDataOverride ?? LoginData();
    _googleSignIn = _googleSignInOverride ?? GoogleSignIn.instance;
    // قراءة حالة تسجيل الدخول الحالية
    if (Get.isRegistered<MyServices>()) {
      final myServices = Get.find<MyServices>();
      isLoggedIn.value =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    // محاولة متعددة للحصول على context صالح
    void tryShow(int attempt) {
      if (attempt > 5) {
        // إذا فشلت جميع المحاولات، استخدم Get.snackbar كبديل
        Get.snackbar(
          isError ? AppStrings.error : 'نجاح',
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
        if (Get.isRegistered<NotificationService>()) {
          NotificationService.instance.syncToken();
        }

        // جلب الدورات من API في الخلفية بدون انتظار
        if (Get.isRegistered<CycleController>()) {
          final cycleController = Get.find<CycleController>();
          // تشغيل في الخلفية بدون await
          unawaited(
            cycleController.fetchCyclesFromServer().catchError((Object error) {
              debugPrint('Error fetching cycles in background: $error');
            }),
          );
        }

        // انتظار وقت قصير لعرض الرسالة قبل إغلاق الصفحة
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        Get.back<void>();
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

      return response.fold((_) => false, (Map<String, dynamic> result) {
        final data = result;
        final isSuccess =
            data['success'] == true || data['status'] == 'success';

        if (isSuccess && data['user'] != null) {
          final userData = data['user'] as Map<String, dynamic>;
          final myServices = Get.find<MyServices>();
          myServices.getStorage.write(StorageKeys.userName, userData['name']);
          if (userData['phone'] != null) {
            myServices.getStorage.write(
              StorageKeys.userPhone,
              userData['phone'].toString(),
            );
          }
          myServices.getStorage.write(StorageKeys.isLoggedIn, true);
          isLoggedIn.value = true; // تحديث observable
          return true;
        }

        return false;
      });
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllLocalData() async {
    final myServices = Get.find<MyServices>();

    // 1. حذف بيانات المستخدم
    await myServices.getStorage.remove(StorageKeys.userName);
    await myServices.getStorage.remove(StorageKeys.userPhone);
    await myServices.getStorage.write(StorageKeys.isLoggedIn, false);

    // 2. حذف كل الدورات والمصاريف والبيانات المخصصة
    if (Get.isRegistered<CycleController>()) {
      final cycleController = Get.find<CycleController>();

      // حذف المصاريف والبيانات المخصصة والملاحظات لكل دورة
      for (var cycle in cycleController.cycles) {
        final cycleName = cycle['name'];
        final cycleId = cycle['id'];

        if (cycleName != null) {
          await myServices.getStorage.remove('${StorageKeys.expensesPrefix}$cycleName');
          await myServices.getStorage.remove('${StorageKeys.customDataPrefix}$cycleName');
          await myServices.getStorage.remove('${StorageKeys.notesPrefix}$cycleName');
        }

        if (cycleId != null) {
          await myServices.getStorage.remove('${StorageKeys.customDataPrefix}$cycleId');
        }
      }

      // تفريغ قائمة الدورات في الـ controller
      cycleController.cycles.clear();
      cycleController.currentCycle.clear();
    }

    // حذف الدورات والدورات المحذوفة
    await myServices.getStorage.remove(StorageKeys.cycles);
    await myServices.getStorage.remove(StorageKeys.deletedCycles);

    // 3. حذف المفضلات
    await myServices.getStorage.remove(StorageKeys.favoriteToolsOrder);
    if (Get.isRegistered<FavoriteToolsController>()) {
      Get.find<FavoriteToolsController>().favoriteToolsOrder.clear();
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Google and Firebase
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear all local data
      await clearAllLocalData();
      isLoggedIn.value = false;

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
