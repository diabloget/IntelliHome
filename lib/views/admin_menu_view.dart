import 'package:flutter/material.dart';
import 'package:intellihome/views/email_service.dart';
import 'package:intellihome/views/user_service.dart';

const Color kPrimaryColor = Color(0xFF176c95);
const Color kAccentColor = Color(0xFFede98a);

class AdminMenuView extends StatefulWidget {
  final String alias;

  const AdminMenuView({Key? key, required this.alias}) : super(key: key);

  @override
  _AdminMenuViewState createState() => _AdminMenuViewState();
}

class _AdminMenuViewState extends State<AdminMenuView> {
  List<Map<String, dynamic>> activeUsers = [];
  List<Map<String, dynamic>> disabledUsers = [];
  bool isAppEnabled = true;
  int _codeExpirationMinutes = 2;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadAppState();
    _checkPasswordChangeReminder();
    _loadCodeExpirationTime();
  }

  Future<void> _loadCodeExpirationTime() async {
    int minutes = await EmailService.getExpirationMinutes();
    setState(() {
      _codeExpirationMinutes = minutes;
    });
  }

  void _showChangeExpirationTimeDialog() {
    final TextEditingController _timeController = TextEditingController(text: _codeExpirationMinutes.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar Tiempo de Expiración'),
          content: TextField(
            controller: _timeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Tiempo en minutos"),
          ),
          backgroundColor: Colors.grey[700],
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                int? newTime = int.tryParse(_timeController.text);
                if (newTime != null && newTime > 0) {
                  await EmailService.setExpirationMinutes(newTime);
                  setState(() {
                    _codeExpirationMinutes = newTime;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tiempo de expiración actualizado')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, ingrese un número válido')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUsers() async {
    final loadedActiveUsers = await UserService.getActiveUsers();
    final loadedDisabledUsers = await UserService.getDisabledUsers();
    setState(() {
      activeUsers = loadedActiveUsers;
      disabledUsers = loadedDisabledUsers;
    });
  }

  Future<void> _loadAppState() async {
    final enabled = await UserService.isAppEnabled();
    setState(() {
      isAppEnabled = enabled;
    });
  }

  Future<void> _checkPasswordChangeReminder() async {
    if (await UserService.shouldRemindPasswordChange()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPasswordChangeReminder();
      });
    }
  }

  void _showPasswordChangeReminder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recordatorio de Seguridad'),
          content: Text('Es recomendable cambiar su contraseña. ¿Desea hacerlo ahora?'),
          backgroundColor: Colors.grey[700],
          actions: <Widget>[
            TextButton(
              child: Text('Más tarde'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cambiar ahora'),
              onPressed: () {
                Navigator.of(context).pop();
                _showChangePasswordDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController _passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar Contraseña'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Nueva contraseña"),
          ),
          backgroundColor: Colors.grey[700],
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                if (_passwordController.text.isNotEmpty) {
                  await UserService.changeAdminPassword(_passwordController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña cambiada exitosamente')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDisableUserDialog(String alias) {
    final TextEditingController _reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deshabilitar Usuario'),
          content: TextField(
            controller: _reasonController,
            decoration: InputDecoration(hintText: "Razón de deshabilitación"),
          ),
          backgroundColor: Colors.grey[700],
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Deshabilitar'),
              onPressed: () async {
                if (_reasonController.text.isNotEmpty) {
                  await UserService.disableUser(alias, _reasonController.text);
                  Navigator.of(context).pop();
                  _loadUsers();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEnableUserDialog(String alias) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Habilitar Usuario'),
          content: Text('¿Está seguro de que desea habilitar a este usuario?'),
          backgroundColor: Colors.grey[700],
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Habilitar'),
              onPressed: () async {
                await UserService.enableUser(alias);
                Navigator.of(context).pop();
                _loadUsers();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menú de Administrador'),
          backgroundColor: kPrimaryColor,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Configuración'),
              Tab(text: 'Usuarios Activos'),
              Tab(text: 'Usuarios Deshabilitados'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildConfigurationTab(),
            _buildUserList(activeUsers, true),
            _buildUserList(disabledUsers, false),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Bienvenido, Admin ${widget.alias}',
            style: TextStyle(fontSize: 24, color: kPrimaryColor),
          ),
        ),
        SwitchListTile(
          title: Text('Habilitar/Deshabilitar Aplicación'),
          value: isAppEnabled,
          activeColor: kPrimaryColor,
          inactiveThumbColor: kPrimaryColor,
          onChanged: (bool value) async {
            await UserService.setAppEnabled(value);
            setState(() {
              isAppEnabled = value;
            });
          },
        ),
        ListTile(
          title: Text('Tiempo de Expiración del Código'),
          subtitle: Text('$_codeExpirationMinutes minutos'),
          trailing: ElevatedButton(
            onPressed: _showChangeExpirationTimeDialog,
            style: ElevatedButton.styleFrom(
              foregroundColor: kAccentColor,
              backgroundColor: kPrimaryColor,
            ),
            child: Text('Cambiar'),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, bool isActiveList) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final bool isAdmin = user['rol'] == 'Admin';
        return ListTile(
          title: Text(user['alias']),
          subtitle: Text(user['correo']),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActiveList && !isAdmin)
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => _promoteUser(context, index),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: kAccentColor,
                      backgroundColor: kPrimaryColor,
                    ),
                    child: Text('Promover'),
                  ),
                ),
              SizedBox(height: 8),
              Flexible(
                child: ElevatedButton(
                  onPressed: isAdmin ? null : () {
                    if (isActiveList) {
                      _showDisableUserDialog(user['alias']);
                    } else {
                      _showEnableUserDialog(user['alias']);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: kAccentColor,
                    backgroundColor: kPrimaryColor,
                  ),
                  child: Text(isActiveList ? 'Deshabilitar' : 'Habilitar'),
                ),
              ),
            ],
          ),
          onTap: isActiveList ? null : () async {
            String? reason = await UserService.getDisableReason(user['alias']);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Razón de Deshabilitación'),
                  content: Text(reason ?? 'No se proporcionó razón'),
                  backgroundColor: Colors.grey[700],
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cerrar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _promoteUser(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar promoción'),
          content: Text('¿Desea promover a ${activeUsers[index]['alias']} como Administrador?'),
          backgroundColor: Colors.grey[700],
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                setState(() {
                  activeUsers[index]['rol'] = 'Admin';
                });
                await UserService.updateUsers([...activeUsers, ...disabledUsers]);
                Navigator.of(context).pop();
                _loadUsers();
              },
            ),
          ],
        );
      },
    );
  }
}