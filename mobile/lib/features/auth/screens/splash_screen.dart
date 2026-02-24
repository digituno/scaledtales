import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../features/home/screens/main_shell.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  void _navigate(BuildContext context, AuthStatus status) {
    if (status == AuthStatus.authenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else if (status == AuthStatus.unauthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      _navigate(context, next.status);
    });

    final authState = ref.read(authProvider);
    if (authState.status != AuthStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigate(context, authState.status);
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'ScaledTales',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
