import 'package:attendx/screens/homescreen.dart';
import 'package:attendx/screens/login.dart';
import 'package:attendx/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://sjnwccolqqvvofwegqtu.supabase.co',
    anonKey: 'sb_publishable_l9wDSd7-Y_9DVvOgaUHLMw_DRLlxz51',
  );
  runApp(const MainApp());
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
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: ThemeData(useMaterial3: true),
      scrollBehavior: NoStretchScrollBehavior(),
    );
  }
}
