import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/local_storage.dart';
import '../screens/login_screen.dart';

final localStorageProvider = Provider((ref) => LocalStorage());

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(localStorageProvider);

    return FutureBuilder<Map<String, String>?>(
      future: storage.getUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          body: Column(
            children: [

              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
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
                child: Column(
                  children: [

                    // Profile avatar
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF0284C7),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${user['firstName']} ${user['lastName']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      user['email'] ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // INFO CARDS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    _infoCard(Icons.person, "First Name", user['firstName']),
                    const SizedBox(height: 10),

                    _infoCard(Icons.person_outline, "Last Name", user['lastName']),
                    const SizedBox(height: 10),

                    _infoCard(Icons.email, "Email", user['email']),

                    const SizedBox(height: 30),

                    // LOGOUT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Logout", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          await storage.logout();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(),
                            ),
                                (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // INFO CARD WIDGET
  Widget _infoCard(IconData icon, String label, String? value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: ${value ?? ''}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}