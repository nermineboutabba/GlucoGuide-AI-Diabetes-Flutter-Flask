import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/glucose_entry.dart';
import '../providers/glucose_history_provider.dart';
import '../providers/prediction_provider.dart';

Color getRiskColor(String risk) {
  switch (risk) {
    case "LOW":
      return Colors.blue;
    case "NORMAL":
      return Colors.green;
    case "HIGH":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String formatDate(DateTime date) {
  return DateFormat('MMM d, HH:mm').format(date);
}

void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    GlucoseEntry item,
    ) {
  final carbsController =
  TextEditingController(text: item.carbs.toString());
  final insulinController =
  TextEditingController(text: item.insulinDose.toString());

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Edit Entry",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: carbsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Carbs (g)",
                prefixIcon: const Icon(Icons.restaurant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: insulinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Insulin",
                prefixIcon: const Icon(Icons.medical_services),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final carbs =
                      double.parse(carbsController.text);
                      final insulin =
                      double.parse(insulinController.text);

                      final api = ref.read(apiProvider);

                      final prediction =
                      await api.predictGlucose(carbs, insulin);

                      final risk = ref
                          .read(glucoseHistoryProvider.notifier)
                          .getRiskLevel(prediction);

                      final advice = ref
                          .read(glucoseHistoryProvider.notifier)
                          .getAdvice(prediction);

                      final updated = GlucoseEntry(
                        id: item.id,
                        carbs: carbs,
                        insulinDose: insulin,
                        prediction: prediction,
                        riskLevel: risk,
                        advice: advice,
                        time: item.time,
                      );

                      ref
                          .read(glucoseHistoryProvider.notifier)
                          .updateEntry(updated);

                      Navigator.pop(context);
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

class GlucoseHistoryScreen extends ConsumerWidget {
  const GlucoseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(glucoseHistoryProvider);

    return Scaffold(
      body: Column(
        children: [

          // MODERN HEADER
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
              "Glucose History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),

                    // Reading metrics
                    title: Text(
                      "${item.carbs}g carbs • ${item.insulinDose} insulin",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 6),

                        Text(
                          "Prediction: ${item.prediction.toStringAsFixed(1)} mg/dL",
                        ),

                        const SizedBox(height: 6),

                        // RISK BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: getRiskColor(item.riskLevel)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.riskLevel,
                            style: TextStyle(
                              color: getRiskColor(item.riskLevel),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(item.advice),

                        const SizedBox(height: 6),

                        // CLEAN DATE
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              formatDate(item.time),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ACTIONS
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDialog(context, ref, item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    "Delete Entry",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                    "Are you sure you want to delete this entry?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        ref.read(glucoseHistoryProvider.notifier)
                                            .deleteEntry(item.id);

                                        Navigator.pop(context);
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}