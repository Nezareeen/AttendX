import 'package:attendx/components/BottomNavigation.dart';
import 'package:attendx/screens/SettingScreen.dart';
import 'package:attendx/screens/attendance_screen.dart';
import 'package:attendx/screens/homescreen.dart';
import 'package:attendx/screens/login.dart';
import 'package:attendx/screens/profile_screen.dart';
import 'package:attendx/services/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://sjnwccolqqvvofwegqtu.supabase.co',
    anonKey: 'sb_publishable_l9wDSd7-Y_9DVvOgaUHLMw_DRLlxz51',
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );

  const storage = FlutterSecureStorage();
  final isLoggedIn = await storage.containsKey(key: 'employeeId');

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
