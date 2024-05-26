import 'package:url_launcher/url_launcher.dart';

class LaunchCoreServiceUtil {
  static Future<void> launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(phoneLaunchUri);
    }
  }

  static Future<void> launchEmail(String? emailAddress) async {
    if (emailAddress != null && emailAddress.isNotEmpty) {
      final Uri emailLaunchUri = Uri(scheme: 'mailto', path: emailAddress);
      await launchUrl(emailLaunchUri);
    }
  }
}
