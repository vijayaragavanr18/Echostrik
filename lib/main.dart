import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'screens/thread_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/threads_screen.dart';
import 'screens/heart_circles_screen.dart';
import 'services/auth_service.dart';
import 'services/audio_service.dart';
import 'services/firebase_service.dart';
import 'services/ai_service.dart';
import 'services/supabase_service.dart';
import 'services/payment_service.dart';
import 'services/live_audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize anonymous auth
  final authService = AuthService();
  await authService.signInAnonymously();

  // Add demo data for testing
  final firebaseService = FirebaseService();
  await firebaseService.addDemoEchoes();

  runApp(const EchoStrikApp());
}

class EchoStrikApp extends StatefulWidget {
  const EchoStrikApp({super.key});

  @override
  State<EchoStrikApp> createState() => _EchoStrikAppState();
}

class _EchoStrikAppState extends State<EchoStrikApp> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    RecordScreen(),
    ThreadsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => SupabaseService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        ChangeNotifierProvider(create: (_) => LiveAudioService()),
        Provider(create: (_) => AIService()),
      ],
      child: MaterialApp(
        title: 'EchoStrik',
        theme: ThemeData(
          primaryColor: const Color(0xFF1A1A2E),
          scaffoldBackgroundColor: const Color(0xFF0F0F23),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF16213E),
            secondary: Color(0xFF0F3460),
            surface: Color(0xFF1A1A2E),
            background: Color(0xFF0F0F23),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
          fontFamily: 'Roboto',
        ),
        home: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
              border: const Border(
                top: BorderSide(
                  color: Color(0xFF0F3460),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mic),
                  label: 'Record',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum),
                  label: 'Threads',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF0F3460),
              unselectedItemColor: Colors.white.withOpacity(0.6),
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
        routes: {
          '/record': (context) => const RecordScreen(),
          '/search': (context) => const SearchScreen(),
          '/threads': (context) => const ThreadsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/circles': (context) => const HeartCirclesScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/thread') {
            final echoId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => ThreadScreen(echoId: echoId),
            );
          }
          return null;
        },
      ),
    );
  }
}
