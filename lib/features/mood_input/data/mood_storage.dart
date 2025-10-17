import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 💾 Esta clase se encarga de manejar el almacenamiento local
/// usando SharedPreferences. Solo trabaja con datos.
class MoodStorage {
  static const String _key = "moods";

  /// Guarda el estado de ánimo para una fecha específica
  static Future<void> saveMood(String dateKey, String mood) async {
    final prefs = await SharedPreferences.getInstance();
    final storedMoods = prefs.getString(_key);
    Map<String, String> moods = {};

    if (storedMoods != null) {
      moods = Map<String, String>.from(json.decode(storedMoods));
    }

    moods[dateKey] = mood;

    await prefs.setString(_key, json.encode(moods));
  }

  /// Obtiene todos los estados de ánimo almacenados
  static Future<Map<String, String>> getAllMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMoods = prefs.getString(_key);
    if (storedMoods == null) return {};
    return Map<String, String>.from(json.decode(storedMoods));
  }

}
