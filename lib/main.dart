import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://lwfqqxywibfhtuwvxwvl.supabase.co", 
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3ZnFxeHl3aWJmaHR1d3Z4d3ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTI3NzIsImV4cCI6MjA4MDg2ODc3Mn0.OzxJcIsob2eWpSOsQSjDZbRitlR_TskLhmD4aF2B8mU",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Supabase.instance.client.auth.currentUser == null
          ? const AuthPage()
          : const HomePage(),
    );
  }
}
