// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:echostrik/main.dart';
import 'package:echostrik/services/auth_service.dart';
import 'package:echostrik/services/audio_service.dart';
import 'package:echostrik/services/firebase_service.dart';

void main() {
  setUpAll(() async {
    // Initialize Firebase for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('App builds and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => AudioService()),
          ChangeNotifierProvider(create: (_) => FirebaseService()),
        ],
        child: const EchoStrikApp(),
      ),
    );

    // Wait for initialization
    await tester.pumpAndSettle();

    // Verify that the app title is shown
    expect(find.text('EchoStrik'), findsOneWidget);
  });
}
