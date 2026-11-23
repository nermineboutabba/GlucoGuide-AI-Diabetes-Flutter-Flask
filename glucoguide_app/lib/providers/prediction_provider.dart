import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiProvider = Provider((ref) => ApiService());

class PredictionState {
  final bool isLoading;
  final double? result;
  final String? error;

  PredictionState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  PredictionState copyWith({
    bool? isLoading,
    double? result,
    String? error,
  }) {
    return PredictionState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

class PredictionNotifier extends StateNotifier<PredictionState> {
  final ApiService api;

  PredictionNotifier(this.api) : super(PredictionState());

  Future<void> predict(double carbs, double insulin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await api.predictGlucose(carbs, insulin);

      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final predictionProvider =
StateNotifierProvider<PredictionNotifier, PredictionState>((ref) {
  return PredictionNotifier(ref.read(apiProvider));
});