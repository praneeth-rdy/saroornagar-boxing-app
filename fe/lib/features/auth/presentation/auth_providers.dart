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

/// Signs out; the route guard reacts to the session change.
final signOutProvider = Provider<Future<void> Function()>(
  (ref) => ref.watch(authRepositoryProvider).signOut,
);

/// Holds the sign-in attempt; failures stay in state as the [AppException].
class SignInController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit({required String phone, required String password}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(phone: phone, password: password);
      // A successful sign-in redirects away, which can dispose this controller.
      if (ref.mounted) state = const AsyncData(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      final failure = error is AppException ? error : const UnknownException();
      state = AsyncError(failure, stackTrace);
    }
  }
}
