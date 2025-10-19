import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../logic/weekly_mood_logic.dart';
import 'weekly_mood_chat.dart';

class MoodStatsScreen extends StatefulWidget {
  const MoodStatsScreen({super.key});

  @override
  State<MoodStatsScreen> createState() => _MoodStatsScreenState();
}

class _MoodStatsScreenState extends State<MoodStatsScreen> {
  final WeeklyMoodLogic _logic = WeeklyMoodLogic();

  List<double?> averages = List<double?>.filled(7, null);
  String? _quote;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadData();
    await _fetchMotivationalQuote();
  }

  /// Carga los datos de estados de ánimo para el rango seleccionado
  Future<void> _loadData() async {
    final computed = await _logic.loadAndCompute(_selectedRange);
    if (mounted) setState(() => averages = computed);
  }

  /// Obtiene una frase motivacional aleatoria desde la API de ZenQuotes
Future<void> _fetchMotivationalQuote() async {
  try {
    final proxyUrl = Uri.parse('https://api.allorigins.win/get?url=https://zenquotes.io/api/random');
    final proxyResponse = await http.get(proxyUrl);

    if (proxyResponse.statusCode == 200) {
      final outer = json.decode(proxyResponse.body);
      final List inner = json.decode(outer['contents']);
      final originalQuote = "${inner[0]['q']} — ${inner[0]['a']}";

      // 🔄 Traducción automática con MyMemory
      final translationUrl = Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(originalQuote)}&langpair=en|es');
      final translationResponse = await http.get(translationUrl);

      if (translationResponse.statusCode == 200) {
        final translationData = json.decode(translationResponse.body);
        final translatedText = translationData['responseData']['translatedText'];
        setState(() => _quote = translatedText);
      } else {
        setState(() => _quote = originalQuote);
      }
    } else {
      setState(() => _quote = "Sigue adelante, cada día cuenta 💪");
    }
  } catch (e) {
    setState(() => _quote = "Error al obtener la frase 😅");
  }
}

  /// Permite seleccionar un rango de fechas
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = averages.any((e) => e != null);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "📊 Estadísticas semanales",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: hasData ? _buildContent() : _buildEmptyState(),
      ),
    );
  }

  /// Muestra el contenido principal con la gráfica y la leyenda
  Widget _buildContent() => Column(
        children: [
          _buildBanner(),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: WeeklyMoodBarChart(values: averages),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildLegendRow(),
        ],
      );

  /// Banner superior con rango de fechas y botón
  Widget _buildBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
        ),
        child: Row(
          children: [
            const Icon(Icons.insights, size: 40, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tu resumen emocional",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedRange == null
                        ? "Selecciona un rango para ver tendencias"
                        : "Del ${_selectedRange!.start.day}/${_selectedRange!.start.month} "
                          "al ${_selectedRange!.end.day}/${_selectedRange!.end.month}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  if (_quote != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _quote!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _pickDateRange,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.date_range),
              label: const Text("Rango"),
            ),
          ],
        ),
      );

  /// Muestra una leyenda de colores para los estados de ánimo
  Widget _buildLegendRow() => Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        children: [
          _buildLegend("😁 Muy Feliz", Colors.yellow.shade600),
          _buildLegend("🙂 Feliz", Colors.green.shade500),
          _buildLegend("😐 Neutral", Colors.grey.shade400),
          _buildLegend("😢 Triste", Colors.lightBlue.shade400),
          _buildLegend("😭 Muy Triste", Colors.red.shade400),
        ],
      );

  Widget _buildLegend(String text, Color color) => Chip(
        backgroundColor: color,
        label: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );

  /// Pantalla vacía si aún no hay datos
  Widget _buildEmptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.black26),
            SizedBox(height: 12),
            Text('Aún no hay datos para mostrar'),
            Text('Registra estados desde la pantalla principal'),
          ],
        ),
      );
}
