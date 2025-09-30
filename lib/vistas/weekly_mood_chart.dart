// lib/vistas/mood_stats.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodStatsScreen extends StatefulWidget {
  const MoodStatsScreen({super.key});

  @override
  State<MoodStatsScreen> createState() => _MoodStatsScreenState();
}

class _MoodStatsScreenState extends State<MoodStatsScreen> {
  Map<String, String> moods = {}; // { "YYYY-MM-DD": "Feliz", ... }
  List<double?> averages = List<double?>.filled(7, null); // lunes..domingo
  DateTimeRange? _selectedRange; // rango de fechas elegido

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

  // Convierte la emoción a un valor numérico (0..4)
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

  // Calcula el promedio para cada día de la semana considerando el rango
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

        // Si hay rango seleccionado, filtramos
        if (_selectedRange != null) {
          if (dt.isBefore(_selectedRange!.start) || dt.isAfter(_selectedRange!.end)) {
            return;
          }
        }

        final idx = dt.weekday - 1; // lunes=0 .. domingo=6
        final value = _moodToValue(mood);
        buckets[idx].add(value);
      } catch (_) {}
    });

    // promedio por bucket
    return buckets.map((list) {
      if (list.isEmpty) return null;
      double sum = 0.0;
      for (final v in list) {
        sum += v;
      }
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
      appBar: AppBar(
        title: const Text('📊 Estadísticas semanales'),
        backgroundColor: Colors.green,
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
                  const Text(
                    'Promedio emocional por día de la semana\n(la barra muestra el promedio y el emoji el estado resultante)',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 📌 Botón para seleccionar rango de fechas
                  ElevatedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _selectedRange == null
                          ? "Seleccionar rango de fechas"
                          : "${_selectedRange!.start.day}/${_selectedRange!.start.month} "
                            " - ${_selectedRange!.end.day}/${_selectedRange!.end.month}",
                    ),
                  ),

                  const SizedBox(height: 18),
                  // Chart area
                  Expanded(
                    child: WeeklyMoodBarChart(values: averages),
                  ),
                  const SizedBox(height: 8),
                  // Leyenda compacta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('😭 Muy triste'),
                      Text('😢 Triste'),
                      Text('😐 Neutral'),
                      Text('🙂 Feliz'),
                      Text('😁 Muy feliz'),
                    ],
                  ),
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
}

/// Widget que dibuja 7 barras (lunes..domingo) con emoji encima.
/// No muestra números para una estética limpia.
class WeeklyMoodBarChart extends StatelessWidget {
  final List<double?> values; // length 7, lunes..domingo
  final double maxValue;
  final double maxBarHeight;
  final double barWidth;

  const WeeklyMoodBarChart({
    super.key,
    required this.values,
    this.maxValue = 4.0,
    this.maxBarHeight = 180.0,
    this.barWidth = 26.0,
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
    final t = (v / maxValue).clamp(0.0, 1.0);
    return Color.lerp(Colors.red.shade600, Colors.green.shade600, t)!;
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
          final barHeight = (v == null) ? 8.0 : (t * maxBarHeight).clamp(8.0, maxBarHeight);
          final color = _colorForValue(v);
          final emoji = _emojiForValue(v);

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  height: barHeight,
                  width: barWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity(0.95),
                        color.withOpacity(0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(weekdayLabels[i], style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
