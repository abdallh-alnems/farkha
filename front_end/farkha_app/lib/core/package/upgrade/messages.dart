import 'package:upgrader/upgrader.dart';

class UpgradeMessages extends UpgraderMessages {
  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'نسخة جديدة متوفرة من تطبيق {{appName}}';
      case UpgraderMessage.buttonTitleLater:
        return 'لاحقا';
      case UpgraderMessage.buttonTitleUpdate:
        return 'تحديث الان';
      case UpgraderMessage.prompt:
        return 'يفضل تحديث التطبيق من اجل عدم مواجهة اي مشاكل';
      case UpgraderMessage.title:
        return 'نسخة جديدة';
      default:
    }

    return super.message(messageKey);
  }
}
