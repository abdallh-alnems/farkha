class PhoneVerificationStrings {
  PhoneVerificationStrings._();

  static const String screenTitle = 'التحقق من رقم الهاتف';
  static const String enterOtpTitle = 'إدخال رمز التحقق';
  static const String phoneHint = 'أدخل رقم الهاتف';
  static const String sendOtpButton = 'إرسال رمز التحقق';
  static const String confirmButton = 'تأكيد';
  static const String resendButton = 'إعادة إرسال الرمز';
  static const String resendCountdown = 'إعادة الإرسال خلال';
  static const String secondsLabel = 'ثانية';

  static const String successVerified = 'تم توثيق رقم الهاتف بنجاح';
  static const String phoneUpdated = 'تم تحديث رقم الهاتف بنجاح';
  static const String otpSent = 'تم إرسال رمز التحقق';
  static const String codeSentTo = 'تم إرسال الرمز إلى';
  static const String verifiedBadge = 'موثّق';

  static const String errorInvalidPhone = 'رقم الهاتف غير صحيح. أدخل رقماً مصرياً صحيحاً';
  static const String errorUnsupportedCountry = 'متاح للأرقام المصرية فقط';
  static const String errorOffline = 'لا يوجد اتصال بالإنترنت';
  static const String errorServer = 'حدث خطأ في الخادم. حاول مرة أخرى';
  static const String errorWrongOtp = 'الرمز غير صحيح';
  static const String errorSessionExpired = 'انتهت صلاحية الرمز. أعد المحاولة';
  static const String errorSessionLocked = 'تم قفل الإدخال مؤقتاً بسبب محاولات خاطئة متكرّرة';
  static const String errorResendLimit = 'تم تجاوز عدد مرّات إعادة الإرسال المسموح';
  static const String errorPhoneAlreadyLinked = 'هذا الرقم مربوط بحساب آخر';
  static const String errorWhatsappFailed = 'فشل إرسال الرسالة. حاول مرة أخرى';

  static const String attemptsRemaining = 'المحاولات المتبقية';
  static const String lockedMessage = 'حاول بعد';
  static const String minutesLabel = 'دقيقة';
  static const String enterCodePrompt = 'أدخل رمز التحقق المكوّن من 6 أرقام';
  static const String didNotReceiveCode = 'لم يصلك الرمز؟';
  static const String verifyPhoneAction = 'توثيق رقم الهاتف';
  static const String changePhoneAction = 'تغيير رقم الهاتف';
  static const String addPhoneAction = 'إضافة رقم الهاتف';
  static const String replacePhoneConfirm = 'سيتم استبدال رقمك الموثّق الحالي. هل تريد المتابعة؟';
  static const String confirm = 'متابعة';
  static const String cancel = 'إلغاء';
  static const String loading = 'جارٍ التحميل...';

  static const String whatsappMessageTemplate = 'رمز التحقق الخاص بك في تطبيق فرخة';
  static const String whatsappExpiryNote = 'ينتهي خلال 10 دقائق. لا تشارك الرمز مع أحد.';
}
