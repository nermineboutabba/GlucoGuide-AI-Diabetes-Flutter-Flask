import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/glucose_entry.dart';
import '../core/local_storage.dart';
import '../services/api_service.dart';

final glucoseHistoryProvider =
StateNotifierProvider<GlucoseHistoryNotifier, List<GlucoseEntry>>((ref) {
  return GlucoseHistoryNotifier();
});

class GlucoseHistoryNotifier extends StateNotifier<List<GlucoseEntry>> {
  final storage = LocalStorage();
  bool isLoading = false;

  GlucoseHistoryNotifier() : super([]);

  Future<void> load() async {
    try {
      final data = await storage.getList('glucose_history');
      state = data.map((e) => GlucoseEntry.fromJson(e)).toList();
    } catch (e) {
      print("Local load failed: $e");
      state = [];
    }
  }

  Future<void> loadFromBackend(String email, ApiService api) async {
    try {
      final data = await api.fetchHistory(email);

      final backendData =
      data.map((e) => GlucoseEntry.fromJson(e)).toList();

      state = backendData;

      // optional cache only (not primary)
      final prefsData =
      backendData.map((e) => e.toJson()).toList();

      await storage.saveList('glucose_history', prefsData);

    } catch (e) {
      print("Backend load failed: $e");

      // fallback ONLY if backend fails
      final local = await storage.getList('glucose_history');
      state = local.map((e) => GlucoseEntry.fromJson(e)).toList();
    }
  }

  Future<void> addEntryWithPrediction(
      double carbs,
      double insulin,
      ApiService api,
      String email,
      ) async {
    isLoading = true;
    state = [...state]; // trigger UI update

    try {
    final prediction = await api.predictGlucose(carbs, insulin);
    final risk = getRiskLevel(prediction);
    final advice = getAdvice(prediction);

    final entry = GlucoseEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      carbs: carbs,
      insulinDose: insulin,
      prediction: prediction,
      riskLevel: risk,
      advice: advice,
      time: DateTime.now(),
    );

    state = [...state, entry];

    // SAVE TO BACKEND
    await api.saveEntry({
      "email": email,
      "carbs": carbs,
      "insulinDose": insulin,
      "prediction": prediction,
      "riskLevel": risk,
      "advice": advice,
      "time": entry.time.toIso8601String(),
    });

    // OPTIONAL local save
    await storage.saveList(
      'glucose_history',
      state.map((e) => e.toJson()).toList(),
    );

    } catch (e, stack) {
      print("ERROR IN addEntryWithPrediction: $e");
      print(stack);
    } finally {
      isLoading = false;
      state = [...state]; // refresh UI
    }
  }

  Future<void> deleteEntry(String id) async {
    state = state.where((e) => e.id != id).toList();

    await storage.saveList(
      'glucose_history',
      state.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> updateEntry(GlucoseEntry updated) async {
    state = [
      for (final e in state)
        if (e.id == updated.id) updated else e
    ];

    await storage.saveList(
      'glucose_history',
      state.map((e) => e.toJson()).toList(),
    );
  }

  String getRiskLevel(double glucose) {
    if (glucose < 70) return "LOW";
    if (glucose <= 140) return "NORMAL";
    return "HIGH";
  }

  String getAdvice(double glucose) {
    if (glucose < 70) {
      return "Your glucose is low. Consider eating fast-acting carbs.";
    } else if (glucose <= 140) {
      return "Your glucose level is normal. Keep maintaining your balance.";
    } else {
      return "High glucose detected. Consider reducing carbs or adjusting insulin.";
    }
  }
}