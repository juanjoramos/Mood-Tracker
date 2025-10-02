import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodStatsScreen extends StatefulWidget {
  const MoodStatsScreen({super.key});

  @override
  State<MoodStatsScreen> createState() => _MoodStatsScreenState();
}

class _MoodStatsScreenState extends State<MoodStatsScreen> {
  Map<String, String> moods = {};
  List<double?> averages = List<double?>.filled(7, null);
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _loadAndCompute();
  }

  Future<void> _loadAndCompute() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('moods');
    if (stored == null) {
      setState(() {
        moods = {};
        averages = List<double?>.filled(7, null);
      });
      return;
    }
    final decoded = Map<String, String>.from(json.decode(stored));
    final computed = _averageByWeekday(decoded);
    setState(() {
      moods = decoded;
      averages = computed;
    });
  }

  double _moodToValue(String mood) {
    switch (mood) {
      case "Muy Triste":
        return 0.0;
      case "Triste":
        return 1.0;
      case "Neutral":
        return 2.0;
      case "Feliz":
        return 3.0;
      case "Muy Feliz":
        return 4.0;
      default:
        return 2.0;
    }
  }

  List<double?> _averageByWeekday(Map<String, String> entries) {
    final buckets = List<List<double>>.generate(7, (_) => []);
    entries.forEach((dateStr, mood) {
      try {
        final parts = dateStr.split('-');
        if (parts.length != 3) return;
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        final dt = DateTime(y, m, d);

        if (_selectedRange != null) {
          if (dt.isBefore(_selectedRange!.start) ||
              dt.isAfter(_selectedRange!.end)) {
            return;
          }
        }

        final idx = dt.weekday - 1;
        final value = _moodToValue(mood);
        buckets[idx].add(value);
      } catch (_) {}
    });

    return buckets.map((list) {
      if (list.isEmpty) return null;
      double sum = list.reduce((a, b) => a + b);
      return sum / list.length;
    }).toList();
  }

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
      setState(() {
        _selectedRange = picked;
        averages = _averageByWeekday(moods);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = averages.any((e) => e != null);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
       title: const Text(
          "📊 Estadísticas semanales",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: _loadAndCompute,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: hasAny
            ? Column(
                children: [
                  // 📌 Nuevo banner con diseño mejorado
                  Container(
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights,
                            size: 40, color: Colors.white),
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
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickDateRange,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.date_range),
                          label: const Text("Rango"),
                        ),
                      ],
                    ),
                  ),

                  // 📊 Chart en tarjeta
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: WeeklyMoodBarChart(values: averages),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Leyenda
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: [
                      _buildLegend("😁 Muy Feliz", Colors.yellow.shade600),
                      _buildLegend("🙂 Feliz", Colors.green.shade500),
                      _buildLegend("😐 Neutral", Colors.grey.shade400),
                      _buildLegend("😢 Triste", Colors.lightBlue.shade400),
                      _buildLegend("😭 Muy Triste", Colors.red.shade400),
                    ],
                  )
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.bar_chart, size: 64, color: Colors.black26),
                    SizedBox(height: 12),
                    Text('Aún no hay datos para mostrar'),
                    Text('Registra estados desde la pantalla principal'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Chip(
      backgroundColor: color,
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Gráfico semanal de moods (lunes..domingo).
class WeeklyMoodBarChart extends StatelessWidget {
  final List<double?> values;
  final double maxValue;
  final double maxBarHeight;
  final double barWidth;

  const WeeklyMoodBarChart({
    super.key,
    required this.values,
    this.maxValue = 4.0,
    this.maxBarHeight = 180.0,
    this.barWidth = 28.0,
  }) : assert(values.length == 7);

  static const weekdayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  String _emojiForValue(double? v) {
    if (v == null) return '—';
    if (v < 0.5) return '😭';
    if (v < 1.5) return '😢';
    if (v < 2.5) return '😐';
    if (v < 3.5) return '🙂';
    return '😁';
  }

  Color _colorForValue(double? v) {
    if (v == null) return Colors.grey.shade300;
    if (v < 0.5) return Colors.red.shade400;
    if (v < 1.5) return Colors.lightBlue.shade400;
    if (v < 2.5) return Colors.grey.shade500;
    if (v < 3.5) return Colors.green.shade500;
    return Colors.yellow.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxBarHeight + 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = values[i];
          final t = (v ?? 0) / maxValue;
          final barHeight =
              (v == null) ? 12.0 : (t * maxBarHeight).clamp(12.0, maxBarHeight);
          final color = _colorForValue(v);
          final emoji = _emojiForValue(v);

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: barHeight,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weekdayLabels[i],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
