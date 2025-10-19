import "package:flutter/material.dart";
import 'package:intl/date_symbol_data_local.dart';

// Importaciones de tus features
import 'features/mood_input/ui/mood_input_screen.dart';
import 'features/calendar/ui/calendar_screen.dart';
import 'features/weekly_mood/ui/weekly_mood_screen.dart';
import 'features/reminder/ui/reminder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); // 🗓️ Inicializa formato de fechas
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainNavigation(), // 👈 inicia con la navegación completa
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1; // 👈 Arranca en el índice del calendario

  // Lista de pantallas disponibles
  final List<Widget> _screens = const [
    MoodInputScreen(),   // índice 0 → Estado de ánimo
    CalendarScreen(),    // índice 1 → Calendario (inicio)
    MoodStatsScreen(),   // índice 2 → Estadísticas
    ReminderScreen(),    // índice 3 → Recordatorios
  ];

  // Controla el cambio de pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_emotions),
            label: 'Estado Ánimo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Recordatorios',
          ),
        ],
      ),
    );
  }
}
