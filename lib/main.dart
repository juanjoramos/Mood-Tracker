import 'package:flutter/material.dart';
import 'vistas/mood_input.dart';
import 'vistas/reminder.dart';
import 'vistas/calendar.dart';
import 'vistas/weekly_mood_chart.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {  
  
  // Inicializa para español
  await initializeDateFormatting('es_ES', null);
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
          backgroundColor: Colors.white,       // color de fondo de la barra
          selectedItemColor: Colors.green,     // ícono/texto del ítem activo
          unselectedItemColor: Colors.grey,    // íconos/textos inactivos
        ),
      ),
      home: const MainNavigation(), // 👈 arrancamos con la navegación
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MoodInputScreen(),   // índice 0 → pantalla inicial    
    CalendarScreen(),    // índice 2
    MoodStatsScreen(),   // índice 3 → 📊 estadísticas
    ReminderScreen(),    // índice 1
  ];

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
        type: BottomNavigationBarType.fixed, // 👈 evita animaciones raras con 4+ items
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
