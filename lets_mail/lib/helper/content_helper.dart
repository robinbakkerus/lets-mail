import 'package:lets_mail/model/email_model.dart';

class ContentHelper {
  // Private constructor to prevent external instantiation.
  ContentHelper._();

  // The single instance of the class.
  static final ContentHelper _instance = ContentHelper._();

  // Factory constructor to provide access to the singleton instance.
  factory ContentHelper() {
    return _instance;
  }

  String buildContent(EmailModel emailModel, String html) {
    String htmlContent = html.replaceAll("%naam%", emailModel.signature);
    return htmlContent;
  }
}
