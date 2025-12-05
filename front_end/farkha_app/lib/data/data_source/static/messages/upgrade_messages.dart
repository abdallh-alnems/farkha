import 'package:upgrader/upgrader.dart';

class UpgradeMessages extends UpgraderMessages {
  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return ''' 

نسخة جديدة من تطبيق فرخة متوفرة الآن 📱

 مميزات جديدة وتحسينات ✨
 إصلاح الأخطاء وتحسين الأداء 🔧
 أمان محسن وحماية أفضل 🛡️

ننصح بتحديث التطبيق للحصول على أفضل تجربة! 💪''';
      case UpgraderMessage.buttonTitleLater:
        return 'لاحقاً';
      case UpgraderMessage.buttonTitleUpdate:
        return 'تحديث الآن';
      case UpgraderMessage.prompt:
        return 'تحديث التطبيق مطلوب لضمان أفضل أداء وتجربة مستخدم';
      case UpgraderMessage.title:
        return 'تحديث متاح';
      default:
    }

    return super.message(messageKey);
  }
}
