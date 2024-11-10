import 'package:url_launcher/url_launcher.dart';

void openGmail() async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'nimss.dev@gmail.com',
  );

  if (await canLaunchUrl(emailLaunchUri)) {
    await launchUrl(emailLaunchUri);
  } else {
    throw 'لا يمكن فتح تطبيق البريد الإلكتروني';
  }
}