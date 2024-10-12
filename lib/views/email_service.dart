import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailService {
  static String? _verificationCode;
  static DateTime? _codeGenerationTime;
  static const String _expirationKey = 'code_expiration_minutes';

  // Credenciales de Gmail
  static const String username = 'henryda2004@gmail.com';
  static const String password = 'xudn kikq plzw ldmm';

  static Future<bool> sendVerificationEmail(String email) async {
    int expirationMinutes = await getExpirationMinutes();
    return await _sendEmail(email, expirationMinutes);
  }

  static Future<bool> sendCustomVerificationEmail(String email, int expirationMinutes) async {
    await setExpirationMinutes(expirationMinutes);
    return await _sendEmail(email, expirationMinutes);
  }

  static Future<bool> _sendEmail(String email, int expirationMinutes) async {
    _verificationCode = _generateVerificationCode();
    _codeGenerationTime = DateTime.now();

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'IntelliHome')
      ..recipients.add(email)
      ..subject = 'Código de Verificación de IntelliHome'
      ..text = 'Tu código de verificación para IntelliHome es: $_verificationCode\n'
          'Este código es válido por $expirationMinutes minutos.';

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

  static Future<bool> verifyCode(String code) async {
    if (_verificationCode == null || _codeGenerationTime == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_codeGenerationTime!);
    int expirationMinutes = await getExpirationMinutes();

    if (difference.inMinutes >= expirationMinutes) {
      _verificationCode = null;
      _codeGenerationTime = null;
      return false;
    }

    return code == _verificationCode;
  }

  static Future<int> getExpirationMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expirationKey) ?? 2; // Default to 2 minutes if not set
  }

  static Future<void> setExpirationMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_expirationKey, minutes);
  }
}