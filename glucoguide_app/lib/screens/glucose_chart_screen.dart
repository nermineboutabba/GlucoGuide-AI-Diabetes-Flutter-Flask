import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/glucose_history_provider.dart';

class GlucoseChartScreen extends ConsumerWidget {
  const GlucoseChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(glucoseHistoryProvider);

    return Scaffold(
      body: Column(
        children: [

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: const Text(
              "Glucose Trends",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: history.isEmpty
                ? const Center(child: Text("No data yet"))
                : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [

                  // Summary stats cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCard("Avg", _avg(history)),
                      _statCard("Min", _getMin(history)),
                      _statCard("Max", _getMax(history)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Line chart card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: LineChart(
                        LineChartData(
                          minY: _getMin(history),
                          maxY: _getMax(history),

                          // Soft grid
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),

                          // Remove outer border
                          borderData: FlBorderData(show: false),

                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),

                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 20,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          lineBarsData: [
                            LineChartBarData(
                              spots: _generateSpots(history),
                              isCurved: true,
                              barWidth: 4,

                              // Gradient line
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0284C7),
                                  Color(0xFF059669),
                                ],
                              ),

                              // Data point markers
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, bar, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(0xFF0284C7),
                                  );
                                },
                              ),

                              // Area fill under curve
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0284C7).withOpacity(0.28),
                                    const Color(0xFF059669).withOpacity(0.08),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Stats card widget
  Widget _statCard(String label, double value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chart data helpers
  List<FlSpot> _generateSpots(List history) {
    return List.generate(history.length, (index) {
      return FlSpot(index.toDouble(), history[index].prediction);
    });
  }

  double _getMin(List history) {
    return history
        .map((e) => e.prediction)
        .reduce((a, b) => a < b ? a : b) -
        10;
  }

  double _getMax(List history) {
    return history
        .map((e) => e.prediction)
        .reduce((a, b) => a > b ? a : b) +
        10;
  }

  double _avg(List history) {
    final sum =
    history.map((e) => e.prediction).reduce((a, b) => a + b);
    return sum / history.length;
  }
}