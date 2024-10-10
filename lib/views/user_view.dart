import 'package:flutter/material.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: const Center(
        child: Text('Pantalla de Usuario'),
      ),
    );
  }
}
