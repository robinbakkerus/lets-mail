import 'package:lets_mail/data/secret_data.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailHelper {
  // Private constructor to prevent external instantiation.
  EmailHelper._();

  // The single instance of the class.
  static final EmailHelper _instance = EmailHelper._();

  // Factory constructor to provide access to the singleton instance.
  factory EmailHelper() {
    return _instance;
  }

  Future<String> sendEmail(
      {required String toEmail,
      required String fromUser,
      required String signature,
      required String subject,
      required String html}) async {
    String username = Credentials().values[fromUser]![0];
    String password = Credentials().values[fromUser]![1];

    final smtpServer = gmail(username, password);

    final message = Message()
          ..from = Address(username, fromUser)
          ..recipients.add(toEmail)
          // ..ccRecipients.addAll(['abc@gmail.com', 'xyz@gmail.com']) // For Adding Multiple Recipients
          // ..bccRecipients.add(Address('a@gmail.com')) For Binding Carbon Copy of Sent Email
          ..subject = subject
          // ..text = 'Hello dear, I am sending you email from Flutter application'
          // ..headers = html
          ..html = html // For Adding Html in email
        // ..attachments = [
        //   FileAttachment(File('image.png'))  //For Adding Attachments
        //     ..location = Location.inline
        //     ..cid = '<myimg@3.141>'
        // ]
        ;

    try {
      await send(message, smtpServer);
      return "";
    } on MailerException catch (e) {
      return e.message;
    }
  }
}
