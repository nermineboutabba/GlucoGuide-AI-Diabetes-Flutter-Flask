import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth_gate.dart';
import '../providers/glucose_history_provider.dart';
import '../providers/prediction_provider.dart';

class AddGlucoseEntryScreen extends ConsumerStatefulWidget {
  const AddGlucoseEntryScreen({super.key});

  @override
  ConsumerState<AddGlucoseEntryScreen> createState() =>
      _AddGlucoseEntryScreenState();
}

class _AddGlucoseEntryScreenState
    extends ConsumerState<AddGlucoseEntryScreen> {
  final carbsController = TextEditingController();
  final insulinController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    carbsController.dispose();
    insulinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // HEADER (same style as other pages)
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
              "Add Glucose Entry",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                // FORM CARD
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Column(
                    children: [

                      // CARBS
                      _field(
                        controller: carbsController,
                        label: "Carbohydrates (g)",
                        icon: Icons.restaurant,
                      ),

                      const SizedBox(height: 15),

                      // INSULIN
                      _field(
                        controller: insulinController,
                        label: "Insulin Dose",
                        icon: Icons.medical_services,
                      ),

                      const SizedBox(height: 25),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Save & Predict",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input field styling
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0284C7)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // SUBMIT LOGIC (your existing logic preserved)
  Future<void> _submit() async {
    try {
      final carbs = double.tryParse(carbsController.text);
      final insulin = double.tryParse(insulinController.text);

      if (carbs == null || insulin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid input")),
        );
        return;
      }

      setState(() => isLoading = true);

      final user = await ref.read(localStorageProvider).getUser();

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final email = user['email'];

      final api = ref.read(apiProvider);
      final history = ref.read(glucoseHistoryProvider.notifier);

      await history.addEntryWithPrediction(
        carbs,
        insulin,
        api,
        email!,
      );

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entry saved successfully")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}