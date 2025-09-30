import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_input.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, String> moods = {}; // {fecha: emocion}

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMoods = prefs.getString("moods");
    if (storedMoods != null) {
      setState(() {
        moods = Map<String, String>.from(json.decode(storedMoods));
      });
    }
  }

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case "Muy Feliz":
        return Colors.yellow.shade600;
      case "Feliz":
        return Colors.green.shade400;
      case "Neutral":
        return Colors.grey;
      case "Triste":
        return Colors.blue.shade400;
      case "Muy Triste":
        return Colors.red.shade400;
      default:
        return Colors.transparent;
    }
  }

  Future<void> _openMoodInput(DateTime date, String? currentMood) async {
    final updatedMood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodInputScreen(
          initialMood: currentMood,
          selectedDate: date,
        ),
      ),
    );

    if (updatedMood != null) {
      await _loadMoods();
      setState(() {
        _selectedDay = DateTime.now(); // vuelve a hoy
        _focusedDay = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = _selectedDay != null
        ? "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}"
        : null;

    final selectedMood = moods[selectedKey];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "📅 Calendario",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Leyenda de colores
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: [
                _buildLegend("Muy Feliz", Colors.yellow.shade600),
                _buildLegend("Feliz", Colors.green.shade400),
                _buildLegend("Neutral", Colors.grey),
                _buildLegend("Triste", Colors.blue.shade400),
                _buildLegend("Muy Triste", Colors.red.shade400),
              ],
            ),
          ),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final key =
                      "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                  final mood = moods[key];
                  if (mood != null) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getMoodColor(mood),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${day.day}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return Center(child: Text("${day.day}"));
                  }
                },
              ),
              calendarFormat: CalendarFormat.month,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Botón de editar debajo
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () =>
                    _openMoodInput(_selectedDay!, selectedMood),
                icon: const Icon(Icons.edit),
                label: Text(selectedMood == null
                    ? "Agregar emoción"
                    : "Editar emoción ($selectedMood)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
