import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.freezed.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.initial) AuthStatus status,
    User? user,
    String? errorMessage,
  }) = _AuthState;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      // 만료된 세션이면 갱신 시도
      if (session.isExpired) {
        try {
          final response = await _supabase.auth.refreshSession();
          if (response.session != null) {
            state = AuthState(
              status: AuthStatus.authenticated,
              user: response.session!.user,
            );
          } else {
            state = const AuthState(status: AuthStatus.unauthenticated);
          }
        } catch (_) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      } else {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: _supabase.auth.currentUser,
        );
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: data.session?.user,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(Supabase.instance.client);
});
