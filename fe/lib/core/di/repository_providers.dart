import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/supabase_auth_repository.dart';
import '../../features/fees/data/fee_repository.dart';
import '../../features/fees/data/supabase_fee_repository.dart';
import '../../features/staff/data/staff_repository.dart';
import '../../features/staff/data/supabase_staff_repository.dart';
import '../../features/today/data/attendance_repository.dart';
import '../../features/today/data/supabase_attendance_repository.dart';
import '../../features/trainees/data/supabase_trainee_repository.dart';
import '../../features/trainees/data/trainee_repository.dart';
import '../../features/trials/data/device_key_store.dart';
import '../../features/trials/data/supabase_trial_repository.dart';
import '../../features/trials/data/trial_repository.dart';
import '../supabase/supabase_client_provider.dart';

/// Supabase implementations; tests override these with the mock repositories.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => SupabaseAttendanceRepository(ref.watch(supabaseClientProvider)),
);

final traineeRepositoryProvider = Provider<TraineeRepository>(
  (ref) => SupabaseTraineeRepository(ref.watch(supabaseClientProvider)),
);

final trialRepositoryProvider = Provider<TrialRepository>(
  (ref) => SupabaseTrialRepository(ref.watch(supabaseClientProvider)),
);

final feeRepositoryProvider = Provider<FeeRepository>(
  (ref) => SupabaseFeeRepository(ref.watch(supabaseClientProvider)),
);

final staffRepositoryProvider = Provider<StaffRepository>(
  (ref) => SupabaseStaffRepository(ref.watch(supabaseClientProvider)),
);

/// Kept for the app's lifetime so the key is read from storage once.
final deviceKeyStoreProvider = Provider<DeviceKeyStore>(
  (ref) => SharedPreferencesDeviceKeyStore(),
);
