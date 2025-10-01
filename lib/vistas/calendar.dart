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
  Map<String, String> moods = {}; // { "yyyy-MM-dd": "Muy Feliz", ... }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadMoods();
  }

  // Carga moods desde SharedPreferences
  Future<void> _loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString("moods");
    if (stored != null && stored.isNotEmpty) {
      setState(() {
        moods = Map<String, String>.from(json.decode(stored));
      });
    } else {
      setState(() {
        moods = {};
      });
    }
  }

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case "Muy Feliz":
        return Colors.yellow.shade600;
      case "Feliz":
        return Colors.green.shade500;
      case "Neutral":
        return Colors.grey.shade400;
      case "Triste":
        return Colors.lightBlue.shade400;
      case "Muy Triste":
        return Colors.red.shade400;
      default:
        return Colors.transparent;
    }
  }

  // Abrir MoodInput y, al regresar, recargar moods y seleccionar la fecha editada
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
        // Seleccionamos y enfocamos la fecha que acabamos de editar (no hoy por fuerza)
        _selectedDay = date;
        _focusedDay = date;
      });
    }
  }

  // Utilidad para convertir DateTime -> "yyyy-MM-dd"
  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final selectedKey =
        _selectedDay != null ? _dateKey(_selectedDay!) : null; 
    final selectedMood = selectedKey != null ? moods[selectedKey] : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "📅 Calendario",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Leyenda (chips suaves)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildLegend("Muy Feliz", Colors.yellow.shade600),
                _buildLegend("Feliz", Colors.green.shade500),
                _buildLegend("Neutral", Colors.grey.shade400),
                _buildLegend("Triste", Colors.lightBlue.shade400),
                _buildLegend("Muy Triste", Colors.red.shade400),
              ],
            ),
            const SizedBox(height: 16),

            // Calendario en tarjeta
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    // El día seleccionado es _selectedDay
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                    // Al seleccionar un día simplemente lo marcamos (no cambiamos colores)
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },

                    // Ocultamos control de formato ("2 weeks")
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    calendarStyle: const CalendarStyle(
                      isTodayHighlighted: false, // evitamos color por defecto en "hoy"
                    ),

                    // Construcción personalizada de celdas
                    calendarBuilders: CalendarBuilders(
                      // Builder general para cada día
                      defaultBuilder: (context, day, focusedDay) {
                        final key = _dateKey(day);
                        final mood = moods[key];
                        final bool isSelected = isSameDay(_selectedDay, day);

                        // Si hay mood -> fondo del color del mood; si no -> blanco
                        final backgroundColor =
                            mood != null ? _getMoodColor(mood) : Colors.white;

                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null, // borde negro si está seleccionado
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${day.day}",
                            style: TextStyle(
                              // si hay mood, número en blanco; si no, negro
                              color: mood != null ? Colors.white : Colors.black87,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },

                      // Para asegurar la misma apariencia en selected (opcional)
                      selectedBuilder: (context, day, focusedDay) {
                        final key = _dateKey(day);
                        final mood = moods[key];
                        final bg = mood != null ? _getMoodColor(mood) : Colors.white;

                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: bg,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${day.day}",
                            style: TextStyle(
                              color: mood != null ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Botón para agregar/editar emoción (minimalista)
            if (_selectedDay != null)
              GestureDetector(
                onTap: () => _openMoodInput(_selectedDay!, selectedMood),
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen.shade400,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        selectedMood == null
                            ? "Agregar emoción"
                            : "Editar emoción ($selectedMood)",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Chip(
      backgroundColor: color,
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
