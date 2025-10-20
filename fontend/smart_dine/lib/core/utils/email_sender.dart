import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../config/email_config.dart';

class EmailSender {
  Future<bool> sendVerificationEmail({
    required String recipient,
    required String code,
  }) async {
    if (!EmailConfig.isConfigured) {
      debugPrint('EmailSender skipped: EmailConfig is not configured.');
      return false;
    }

    final server = SmtpServer(
      EmailConfig.smtpHost,
      port: EmailConfig.smtpPort,
      username: EmailConfig.username,
      password: EmailConfig.password,
      ssl: !EmailConfig.useTls,
      ignoreBadCertificate: EmailConfig.ignoreBadCertificate,
    );

    final message =
        Message()
          ..from = Address(EmailConfig.username, EmailConfig.fromName)
          ..recipients.add(recipient)
          ..subject = 'Smart Dine - mã xác minh của bạn'
          ..text = 'Mã xác minh của bạn là $code. Mã sẽ hết hạn sau 5 phút.'
          ..html =
              '<p>Xin chào,</p><p>Mã xác minh của bạn là <strong>$code</strong>.</p><p>Mã sẽ hết hạn sau 5 phút.</p><p>Trân trọng,<br/>Smart Dine</p>';

    try {
      await send(message, server);
      return true;
    } on MailerException catch (err) {
      debugPrint(
        'MailerException: ${err.problems.map((p) => p.code).join(', ')}',
      );
      return false;
    } catch (err) {
      debugPrint('sendVerificationEmail error: $err');
      return false;
    }
  }
}

final emailSenderProvider = Provider<EmailSender>((ref) => EmailSender());
