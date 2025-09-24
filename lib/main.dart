import 'package:flutter/material.dart';
import 'vistas/mood_input.dart';
import 'vistas/reminder.dart';
import 'vistas/calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/mood_input': (context) => const MoodInputScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/reminders': (context) => const ReminderScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Mood Tracker"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/mood_input'),
              child: const Text("Ir a Mood Input"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/reminders'),
              child: const Text("Ir a Recordatorios"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/calendar'),
              child: const Text("Ir al Calendario"),
            ),
          ],
        ),
      ),
    );
  }
}
