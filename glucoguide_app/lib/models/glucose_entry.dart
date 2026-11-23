class GlucoseEntry {
  final String id;
  final double carbs;
  final double insulinDose;
  final double prediction;
  final String riskLevel;
  final String advice;
  final DateTime time;

  GlucoseEntry({
    required this.id,
    required this.carbs,
    required this.insulinDose,
    required this.prediction,
    required this.riskLevel,
    required this.advice,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'carbs': carbs,
    'insulinDose': insulinDose,
    'prediction': prediction,
    'riskLevel': riskLevel,
    'advice': advice,
    'time': time.toIso8601String(),
  };

  factory GlucoseEntry.fromJson(Map<String, dynamic> json) {
    return GlucoseEntry(
      id: json['id'] ?? DateTime.now().toString(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      insulinDose: (json['insulinDose'] ?? 0).toDouble(),
      prediction: (json['prediction'] ?? 0).toDouble(),
      riskLevel: json['riskLevel'] ?? "UNKNOWN",
      advice: json['advice'] ?? "No advice available",
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
    );
  }
}