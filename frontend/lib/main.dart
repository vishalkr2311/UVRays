// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/firebase_service.dart';
import 'theme/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('main() before FirebaseService.initialize');
  try {
    await FirebaseService().initialize();
  } catch (e, st) {
    print('FirebaseService.initialize failed: $e');
    print(st);
  }
  print('main() after FirebaseService.initialize');

  runApp(
    const ProviderScope(
      child: BlindMeetApp(),
    ),
  );
}

class BlindMeetApp extends StatelessWidget {
  const BlindMeetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlindMeet',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/admin': (context) => const AdminScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Placeholder for Home Screen (will be expanded)
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: const Center(
          child: Text('Home Screen'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppTheme.cardDark,
        selectedItemColor: AppTheme.accentNeon,
        unselectedItemColor: AppTheme.textTertiary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Accepted'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
