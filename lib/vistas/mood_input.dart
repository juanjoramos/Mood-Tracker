import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MoodInputScreen extends StatefulWidget {
  final String? initialMood;
  final DateTime? selectedDate;

  const MoodInputScreen({
    super.key,
    this.initialMood,
    this.selectedDate,
  });

  @override
  State<MoodInputScreen> createState() => _MoodInputScreenState();
}

class _MoodInputScreenState extends State<MoodInputScreen> {
  String? selectedMood;

  final Map<String, Map<String, dynamic>> moodOptions = {
    "Muy Feliz": {"emoji": "😁", "color": Colors.yellow.shade700},
    "Feliz": {"emoji": "😊", "color": Colors.green.shade400},
    "Neutral": {"emoji": "😐", "color": Colors.grey.shade500},
    "Triste": {"emoji": "😔", "color": Colors.blue.shade400},
    "Muy Triste": {"emoji": "😭", "color": Colors.red.shade400},
  };

  @override
  void initState() {
    super.initState();
    selectedMood = widget.initialMood;
  }

  Future<void> _saveMood() async {
    if (selectedMood == null || widget.selectedDate == null) return;

    final prefs = await SharedPreferences.getInstance();
    final storedMoods = prefs.getString("moods");
    Map<String, String> moods = {};

    if (storedMoods != null) {
      moods = Map<String, String>.from(json.decode(storedMoods));
    }

    final dateKey = DateFormat("yyyy-MM-dd").format(widget.selectedDate!);

    moods[dateKey] = selectedMood!;

    await prefs.setString("moods", json.encode(moods));

    Navigator.pop(context, selectedMood);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = widget.selectedDate != null
        ? DateFormat("EEEE, d 'de' MMMM yyyy", "es_ES")
            .format(widget.selectedDate!)
        : DateFormat("EEEE, d 'de' MMMM yyyy", "es_ES").format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Banner superior con degradado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_emotions, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Tu estado de ánimo importa 💚",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // 📌 Opciones de emociones
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: moodOptions.entries.map((entry) {
                  final mood = entry.key;
                  final emoji = entry.value["emoji"];
                  final color = entry.value["color"];

                  final isSelected = selectedMood == mood;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = mood;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? color.withOpacity(0.5)
                                : Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 🟢 Botón elegante de guardar al final
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedMood != null ? _saveMood : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      selectedMood != null ? Colors.green : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Guardar",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
