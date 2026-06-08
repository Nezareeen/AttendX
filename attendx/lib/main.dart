import 'package:attendx/components/bottom_navigation.dart';
import 'package:attendx/screens/setting_screen.dart';
import 'package:attendx/screens/attendance_screen.dart';
import 'package:attendx/screens/homescreen.dart';
import 'package:attendx/screens/login.dart';
import 'package:attendx/screens/profile_screen.dart';
import 'package:attendx/services/localstorage.dart';
import 'package:attendx/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendx/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseUrl = Env.supabaseUrl;
  final supabaseAnonKey = Env.supabaseAnonKey;

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      "Missing Supabase credentials. Ensure SUPABASE_URL and SUPABASE_ANON_KEY are present in the .env file "
      "before running build_runner.",
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );

  // Validate stored session token instead of just checking for an ID
  bool isLoggedIn = false;
  if (await AuthService.hasStoredSession()) {
    final authService = AuthService(Supabase.instance.client);
    final employee = await authService.validateSession();
    isLoggedIn = employee != null;
  }

  runApp(
    ProviderScope(
      child: MainApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class NoStretchScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      scrollBehavior: NoStretchScrollBehavior(),
      initialRoute: isLoggedIn ? '/main' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/main': (context) => const CustomBottomNavBar(),
        'Home': (context) => const Homescreen(),
        'Attendance': (context) => const AttendanceScreen(),
        'Profile': (context) => const ProfileScreen(),
        'Settings': (context) => const Settingscreen(),
      },
    );
  }
}
