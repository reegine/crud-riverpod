import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth.dart';
import '../provider/auth_provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final authService = ref.read(authServiceProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    // TextEditingController emailController = TextEditingController(text: user?.email ?? '');

    // Future<void> _showUpdateEmailDialog() async {
    //   emailController.text = user?.email ?? '';
    //
    //   await showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: const Text('Update Email'),
    //       content: TextField(
    //         controller: emailController,
    //         decoration: const InputDecoration(
    //           labelText: 'Email',
    //         ),
    //         keyboardType: TextInputType.emailAddress,
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: const Text('Cancel'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () async {
    //             final newEmail = emailController.text.trim();
    //             if (newEmail.isEmpty) {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 const SnackBar(content: Text('Email cannot be empty')),
    //               );
    //               return;
    //             }
    //             Navigator.pop(context);
    //
    //             try {
    //               // Call update email method
    //               if (user != null) {
    //                 final updatedUser  = await authService.updateUserEmail(user.token, newEmail);
    //                 // Update the state with new user info
    //                 authNotifier.state = updatedUser ;
    //                 ScaffoldMessenger.of(context).showSnackBar(
    //                     const SnackBar(content: Text('Email updated successfully')));
    //               }
    //             } catch (e) {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                   SnackBar(content: Text('Failed to update email: $e')));
    //             }
    //           },
    //           child: const Text('Update'),
    //         )
    //       ],
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<AuthUser>(
          future: user != null ? authService.fetchUserInfo(user.token) : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('No user data found.');
            }

            final fetchedUser  = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, ${fetchedUser .username.isNotEmpty ? fetchedUser .username : 'User '}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Email: ${fetchedUser .email}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // ElevatedButton(
                //   onPressed: _showUpdateEmailDialog,
                //   child: const Text('Update Email'),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}