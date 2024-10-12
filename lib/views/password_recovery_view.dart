import 'package:flutter/material.dart';
import 'package:intellihome/views/email_service.dart';
import 'package:intellihome/views/user_service.dart';
import 'package:intellihome/views/login_view.dart';
import 'dart:async';

import '../login/login_view.dart';

const Color kPrimaryColor = Color(0xFF176c95);
const Color kAccentColor = Color(0xFFede98a);

class PasswordRecoveryView extends StatefulWidget {
  const PasswordRecoveryView({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryViewState createState() => _PasswordRecoveryViewState();
}

class _PasswordRecoveryViewState extends State<PasswordRecoveryView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String _currentStep = 'email'; // 'email', 'code', 'password'
  int _expirationMinutes = 2; // Default value
  Timer? _expirationTimer;
  DateTime? _expirationTime;

  @override
  void initState() {
    super.initState();
    _loadExpirationTime();
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadExpirationTime() async {
    int minutes = await EmailService.getExpirationMinutes();
    setState(() {
      _expirationMinutes = minutes;
    });
  }

  void _handleEmailSubmit() async {
    final email = _emailController.text;
    final users = await UserService.getUsers();
    final userExists = users.any((user) => user['correo'] == email);

    if (userExists) {
      // Asegúrate de obtener el tiempo de expiración más reciente
      _expirationMinutes = await EmailService.getExpirationMinutes();
      final emailSent = await EmailService.sendVerificationEmail(email);
      if (emailSent) {
        setState(() {
          _currentStep = 'code';
          _expirationTime = DateTime.now().add(Duration(minutes: _expirationMinutes));
        });
        _startExpirationTimer();
      } else {
        _showErrorMessage('Error al enviar el correo. Intente nuevamente.');
      }
    } else {
      _showErrorMessage('Si el correo existe, recibirá un código de verificación.');
    }
  }

  void _startExpirationTimer() {
    _expirationTimer?.cancel(); // Cancel any existing timer
    _expirationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_expirationTime != null) {
        final remaining = _expirationTime!.difference(DateTime.now());
        if (remaining.isNegative) {
          timer.cancel();
          if (mounted && _currentStep == 'code') {
            _showErrorMessage('El código ha expirado. Por favor, solicite uno nuevo.');
            _navigateToLoginView();
          }
        } else {
          setState(() {
            // Update the UI to show the remaining time
          });
        }
      }
    });
  }

  void _navigateToLoginView() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }

  void _handleCodeSubmit() async {
    final code = _codeController.text;
    final isValid = await EmailService.verifyCode(code);
    if (isValid) {
      _expirationTimer?.cancel(); // Cancel the timer as code is verified
      setState(() {
        _currentStep = 'password';
      });
    } else {
      _showErrorMessage('Código incorrecto o expirado.');
      _navigateToLoginView();
    }
  }

  void _handlePasswordChange() async {
    final newPassword = _newPasswordController.text;
    final email = _emailController.text;
    final users = await UserService.getUsers();
    final userIndex = users.indexWhere((user) => user['correo'] == email);

    if (userIndex != -1) {
      users[userIndex]['contrasena'] = newPassword;
      await UserService.updateUsers(users);
      _showSuccessMessage('Contraseña cambiada exitosamente.');
      _navigateToLoginView();
    } else {
      _showErrorMessage('Error al cambiar la contraseña.');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperación de Contraseña'),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 'email':
        return _buildEmailStep();
      case 'code':
        return _buildCodeStep();
      case 'password':
        return _buildPasswordStep();
      default:
        return Container();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Correo Electrónico'),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _handleEmailSubmit,
          style: ElevatedButton.styleFrom(
            foregroundColor: kAccentColor,
            backgroundColor: kPrimaryColor,
          ),
          child: const Text('Enviar Código'),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    String remainingTime = '';
    if (_expirationTime != null) {
      final remaining = _expirationTime!.difference(DateTime.now());
      if (remaining.isNegative) {
        remainingTime = 'El código ha expirado';
      } else {
        remainingTime = '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
      }
    }

    return Column(
      children: [
        TextField(
          controller: _codeController,
          decoration: const InputDecoration(labelText: 'Código de Verificación'),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _handleCodeSubmit,
          style: ElevatedButton.styleFrom(
            foregroundColor: kAccentColor,
            backgroundColor: kPrimaryColor,
          ),
          child: const Text('Verificar Código'),
        ),
        const SizedBox(height: 8.0),
        Text('Tiempo restante: $remainingTime'),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        TextField(
          controller: _newPasswordController,
          decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
          obscureText: true,
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _handlePasswordChange,
          style: ElevatedButton.styleFrom(
            foregroundColor: kAccentColor,
            backgroundColor: kPrimaryColor,
          ),
          child: const Text('Cambiar Contraseña'),
        ),
      ],
    );
  }
}