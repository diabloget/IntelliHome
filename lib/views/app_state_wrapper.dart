import 'package:flutter/material.dart';
import 'package:intellihome/views/user_service.dart';

class AppStateWrapper extends StatefulWidget {
  final Widget child;
  final String userAlias;

  const AppStateWrapper({Key? key, required this.child, required this.userAlias}) : super(key: key);

  @override
  _AppStateWrapperState createState() => _AppStateWrapperState();
}

class _AppStateWrapperState extends State<AppStateWrapper> {
  late Future<bool> _appStateFuture;

  @override
  void initState() {
    super.initState();
    _appStateFuture = _checkAppState();
  }

  Future<bool> _checkAppState() async {
    if (widget.userAlias == 'Admin') {
      return true; // El Admin siempre puede acceder
    }
    return await UserService.isAppEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _appStateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data!) {
          return widget.child;
        } else {
          return Scaffold(
            body: Center(
              child: Text('La aplicación está deshabilitada temporalmente.'),
            ),
          );
        }
      },
    );
  }
}