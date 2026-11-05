import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/supabase_auth_repository.dart';
import '../supabase/supabase_client_provider.dart';

/// Supabase implementations; tests override these with the mock repositories.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);
