import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/repository_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/staff_profile.dart';

/// Whether someone is signed in: the current state first, then every change.
final sessionProvider = StreamProvider<bool>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield repository.hasSession;
  yield* repository.sessionChanges;
});

final currentProfileProvider = FutureProvider.autoDispose<StaffProfile>(
  (ref) => ref.watch(authRepositoryProvider).currentProfile(),
);

final signInControllerProvider =
    NotifierProvider.autoDispose<SignInController, AsyncValue<void>>(
      SignInController.new,
    );

final passwordResetRequestControllerProvider =
    NotifierProvider.autoDispose<
      PasswordResetRequestController,
      AsyncValue<void>
    >(PasswordResetRequestController.new);

final passwordResetControllerProvider =
    NotifierProvider.autoDispose<PasswordResetController, AsyncValue<void>>(
      PasswordResetController.new,
    );

/// Signs out; the route guard reacts to the session change.
final signOutProvider = Provider<Future<void> Function()>(
  (ref) => ref.watch(authRepositoryProvider).signOut,
);

/// Holds the sign-in attempt; failures stay in state as the [AppException].
class SignInController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      // A successful sign-in redirects away, which can dispose this controller.
      if (ref.mounted) state = const AsyncData(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      final failure = error is AppException ? error : const UnknownException();
      state = AsyncError(failure, stackTrace);
    }
  }
}

/// Asks for a recovery code by email; failures stay in state as the [AppException].
class PasswordResetRequestController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns whether the code was requested.
  Future<bool> send(String email) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(email);
      if (ref.mounted) state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(_asAppException(error), stackTrace);
      return false;
    }
  }
}

/// Verifies the recovery code and sets the new password.
class PasswordResetController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns null when the password was set, else the failure (also kept in state).
  /// Callers check [state] first: a call while one runs is not ignored here.
  Future<AppException?> complete({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    try {
      await repository.completePasswordReset(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      // The new session redirects away, which can dispose this controller.
      if (ref.mounted) state = const AsyncData(null);
      return null;
    } catch (error, stackTrace) {
      final failure = _asAppException(error);
      if (ref.mounted) state = AsyncError(failure, stackTrace);
      return failure;
    }
  }
}

AppException _asAppException(Object error) =>
    error is AppException ? error : const UnknownException();
