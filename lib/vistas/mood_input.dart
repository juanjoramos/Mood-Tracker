import 'package:flutter/material.dart';

class MoodInputScreen extends StatefulWidget {
  const MoodInputScreen({super.key});

  @override
  State<MoodInputScreen> createState() => _MoodInputScreenState();
}

class _MoodInputScreenState extends State<MoodInputScreen> {
  String selectedMood = "";

  Widget moodButton(String mood, String emoji) {
    return ElevatedButton(
      onPressed: () {
        setState(() => selectedMood = mood);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedMood == mood
            ? Colors.green[100]
            : Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(mood, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "¿Cómo te sientes hoy?",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.lightBlue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            moodButton("Muy Feliz", "😄"),
            const SizedBox(height: 10),
            moodButton("Feliz", "😊"),
            const SizedBox(height: 10),
            moodButton("Neutral", "😐"),
            const SizedBox(height: 10),
            moodButton("Triste", "😟"),
            const SizedBox(height: 10),
            moodButton("Muy Triste", "😭"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedMood.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Estado guardado: $selectedMood")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Guardar Estado de Ánimo"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
        ],
        //onTap: (index) {
        //if (index == 1) Navigator.pushNamed(context, '/reminders');
        //if (index == 2) Navigator.pushNamed(context, '/calendar');
        //},
      ),
    );
  }
}
