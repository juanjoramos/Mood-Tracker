import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../logic/mood_controller.dart';

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
  late MoodController controller;

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
    controller = MoodController(moodOptions);
    controller.selectedMood = widget.initialMood;
  }

  // ✅ Método actualizado: guarda con fecha actual si no se pasa ninguna
  Future<void> _saveMood() async {
    // Si no hay emoción elegida, no hacemos nada
    if (controller.selectedMood == null) return;

    // Si no viene fecha desde el calendario, usamos la de hoy
    final date = widget.selectedDate ?? DateTime.now();

    // Guardar el estado de ánimo
    await controller.saveMood(date);

    // Mostrar confirmación
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "✅ Tu estado de ánimo ha sido guardado correctamente",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Esperar un instante para mostrar el mensaje antes de cerrar
    await Future.delayed(const Duration(milliseconds: 800));

    // ✅ Cerramos y devolvemos true para indicar que hubo guardado
    
  }

  @override
  Widget build(BuildContext context) {
    final dateText = widget.selectedDate != null
        ? DateFormat("EEEE, d 'de' MMMM yyyy", "es_ES")
            .format(widget.selectedDate!)
        : DateFormat("EEEE, d 'de' MMMM yyyy", "es_ES")
            .format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 🌈 Banner superior
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

                  final isSelected = controller.selectedMood == mood;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.selectedMood = mood;
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
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
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

          // 🟢 Botón de guardar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.selectedMood != null ? _saveMood : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      controller.selectedMood != null ? Colors.green : Colors.grey,
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
