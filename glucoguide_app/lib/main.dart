import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth_gate.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoGuide',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFF059669),
        ),

        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyMedium: const TextStyle(fontSize: 15),
          titleLarge: const TextStyle(fontWeight: FontWeight.bold),
        ),

        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}