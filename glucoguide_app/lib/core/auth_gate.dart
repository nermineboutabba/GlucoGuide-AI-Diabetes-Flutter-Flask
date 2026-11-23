import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage.dart';
import '../providers/glucose_history_provider.dart';
import '../providers/prediction_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';

final localStorageProvider = Provider((ref) => LocalStorage());

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final api = ref.read(apiProvider);
    final user = await ref.read(localStorageProvider).getUser();

    if (user != null) {
      final email = user['email'] as String;

      await ref
          .read(glucoseHistoryProvider.notifier)
          .loadFromBackend(email, api);
    }

    await Future.delayed(const Duration(seconds: 1)); // small UX delay

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}