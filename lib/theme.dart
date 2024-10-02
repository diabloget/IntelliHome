import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: const Color(0xFFede98a), // Color Primario
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch:
          Colors.yellow, // Color aproximado para generar tonos primarios
    ).copyWith(
      secondary: const Color(0xFF176c95), // Color Secundario
      primary: const Color(
          0xFFede98a), // Color Primario ajustado al esquema de colores
    ),
    scaffoldBackgroundColor:
        const Color.fromRGBO(43, 45, 49, 1), // Fondo de la pantalla
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'FiraCode',
        fontSize: 32, // Tamaño base para encabezados grandes
        color: Color(0xFFfbf9e8), // Color del texto
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'FiraCode',
        fontSize: 16, // Tamaño base para el cuerpo de texto
        color: Color(0xFFfbf9e8), // Color del texto
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            const Color(0xFF176c95), // Color de los botones elevados
        textStyle: const TextStyle(
          fontFamily: 'FiraCode',
          color: Color(0xFFfbf9e8), // Color del texto del botón
        ),
      ),
    ),
  );
}
