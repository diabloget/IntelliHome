import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static String? _verificationCode;
  static DateTime? _codeGenerationTime;

  // Credenciales de Gmail
  static const String username = 'henryda2004@gmail.com';
  static const String password = 'xudn kikq plzw ldmm';

  static Future<bool> sendVerificationEmail(String email) async {
    _verificationCode = _generateVerificationCode();
    _codeGenerationTime = DateTime.now();

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'IntelliHome')
      ..recipients.add(email)
      ..subject = 'Código de Verificación de IntelliHome'
      ..text = 'Tu código de verificación para IntelliHome es: $_verificationCode\n'
          'Este código es válido por 2 minutos.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Correo enviado: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Error al enviar el correo: $e');
      return false;
    }
  }

  static String _generateVerificationCode() {
    var rng = Random();
    return List.generate(5, (_) => rng.nextInt(10)).join();
  }

  static bool verifyCode(String code) {
    if (_verificationCode == null || _codeGenerationTime == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_codeGenerationTime!);

    if (difference.inMinutes >= 2) {
      _verificationCode = null;
      _codeGenerationTime = null;
      return false;
    }

    return code == _verificationCode;
  }
}