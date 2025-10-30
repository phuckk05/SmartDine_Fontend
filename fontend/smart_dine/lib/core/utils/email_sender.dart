import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  static const String _username =
      'phuckk2101@gmail.com'; // ĐỔI SANG GMAIL CÁ NHÂN
  static const String _password =
      'gxhfjbdihfxeuaew'; // ĐỔI SANG APP PASSWORD MỚI
  static const String _fromName = 'smart_dine';

  Future<bool> sendVerificationEmail({
    required String recipient,
    required String code,
  }) async {
    debugPrint('=== Starting email send ===');
    debugPrint('Recipient: $recipient');
    debugPrint('Code: $code');
    debugPrint('Username: $_username');

    try {
      // Sử dụng helper gmail()
      final smtpServer = gmail(_username, _password);

      final message =
          Message()
            ..from = Address(_username, _fromName)
            ..recipients.add(recipient)
            ..subject = 'Smart Dine - Mã xác minh của bạn'
            ..text = 'Mã xác minh của bạn là: $code. Mã sẽ hết hạn sau 5 phút.'
            ..html =
                '<p>Xin chào,</p><p>Mã xác minh của bạn là <strong>$code</strong>.</p><p>Mã sẽ hết hạn sau 5 phút.</p><p>Trân trọng,<br/>Smart Dine</p>';

      debugPrint('Sending email...');
      final sendReport = await send(message, smtpServer);
      debugPrint('✅ Email sent successfully: ${sendReport.toString()}');
      return true;
    } on MailerException catch (err) {
      debugPrint('❌ MailerException occurred:');
      debugPrint('  Problems count: ${err.problems.length}');
      for (var problem in err.problems) {
        debugPrint('  - Code: ${problem.code}');
        debugPrint('    Message: ${problem.msg}');
      }
      return false;
    } catch (err, stackTrace) {
      debugPrint('❌ Unexpected error: $err');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
}

final emailSenderProvider = Provider<EmailSender>((ref) => EmailSender());
