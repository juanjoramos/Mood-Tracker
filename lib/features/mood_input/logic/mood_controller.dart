import 'package:intl/intl.dart';
import '../data/mood_storage.dart';

/// 🧠 Controla la lógica del negocio.
/// Decide cómo formatear la fecha, qué emoción está seleccionada y cómo guardarla.
class MoodController {
  String? selectedMood;

  final Map<String, Map<String, dynamic>> moodOptions;

  MoodController(this.moodOptions);

  /// Convierte la fecha a formato "yyyy-MM-dd"
  String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  /// Guarda el estado de ánimo actual usando MoodStorage
  Future<void> saveMood(DateTime selectedDate) async {
    if (selectedMood == null) return;
    final dateKey = formatDate(selectedDate);
    await MoodStorage.saveMood(dateKey, selectedMood!);
  }
}