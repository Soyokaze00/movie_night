import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'providers/movie_provider.dart';
import 'screens/main_shell.dart';
import 'screens/profile_setup_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initDatabaseFactory();
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (context) => MovieProvider(),
      child: const MyApp(),
    ),
  );
}

/// sqflite only talks to a native SQLite lib out of the box (Android/iOS/
/// macOS). Chrome has no such thing, and plain Windows/Linux desktop builds
/// don't ship one either, so both need an ffi-based factory instead.
void _initDatabaseFactory() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android/iOS/macOS: leave the default sqflite factory as-is.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Night',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9000FF), 
          brightness: Brightness.dark, 
          primary: const Color(0xFF8000FF), 
          secondary: const Color(0xFFFA63FF), 
          surface: const Color(0xFF1E1E1E), 
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
          titleSmall: TextStyle(color: Colors.white), 
        ),
        useMaterial3: true,
      ),
      home: const AppGate(),
    );
  }
}

/// Waits for the local profile to load, then sends first-time users to
/// profile setup and everyone else straight into the app.
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        if (!provider.isProfileReady) {
          return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
        }
        return provider.hasProfile ? const MainShell() : const ProfileSetupScreen(isFirstRun: true);
      },
    );
  }
}
