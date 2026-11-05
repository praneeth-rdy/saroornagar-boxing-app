import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/trainee_status.dart';
import '../../../core/supabase/supabase_errors.dart';
import '../../../core/utils/india_date.dart';
import '../domain/attendance_record.dart';
import '../domain/trainee.dart';
import '../domain/trainee_input.dart';
import 'trainee_repository.dart';

const _photoBucket = 'trainee-photos';
const _signedUrlLifetime = Duration(hours: 1);

// A URL this close to expiry is renewed, so an image never loads from a dead link.
const _signedUrlMargin = Duration(minutes: 5);

class SupabaseTraineeRepository implements TraineeRepository {
  SupabaseTraineeRepository(this.client);

  final SupabaseClient client;
  final _signedUrls = <String, ({String url, DateTime expiresAt})>{};
  final _random = Random.secure();

  @override
  Future<List<Trainee>> list({required TraineeStatus status}) =>
      guardSupabase(() async {
        final rows = await client
            .from('trainees')
            .select()
            .eq('status', status.wire)
            .order('full_name');
        // The server orders by lower(full_name); collation alone may not.
        return rows.map(Trainee.fromJson).toList()..sort(_byName);
      });

  @override
  Future<Trainee> byId(String id) => guardSupabase(() async {
    final row = await client
        .from('trainees')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) throw const NotFoundException('Trainee not found');
    return Trainee.fromJson(row);
  });

  @override
  Future<Trainee> create(TraineeInput input) =>
      _trainee('create_trainee', _inputParams(input));

  @override
  Future<Trainee> update(String id, TraineeInput input) =>
      _trainee('update_trainee', {'p_trainee_id': id, ..._inputParams(input)});

  @override
  Future<Trainee> setStatus(String id, TraineeStatus status) async {
    // The enum cast would fail as an unmapped error; the server's message is the same.
    if (status == TraineeStatus.unknown) {
      throw const ValidationException('Choose a status');
    }
    return _trainee('set_trainee_status', {
      'p_trainee_id': id,
      'p_status': status.wire,
    });
  }

  @override
  Future<Trainee> uploadPhoto(
    String id,
    Uint8List bytes,
    String fileName,
  ) async {
    final type = _photoTypeOf(fileName);
    final path = '$id/${_randomUuid()}.${type.extension}';
    await guardSupabase(
      () => _storage(
        () => client.storage
            .from(_photoBucket)
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: type.contentType),
            ),
      ),
    );
    try {
      return await _trainee('set_trainee_photo', {
        'p_trainee_id': id,
        'p_photo_path': path,
      });
    } on AppException {
      // The object is unlinked, so removing it is only tidying; a failure leaves an orphan.
      client.storage.from(_photoBucket).remove([path]).ignore();
      rethrow;
    }
  }

  @override
  Future<Trainee> removePhoto(String id) =>
      _trainee('set_trainee_photo', {'p_trainee_id': id, 'p_photo_path': null});

  @override
  Future<String?> photoUrl(String? photoPath) async {
    if (photoPath == null) return null;
    final cached = _signedUrls[photoPath];
    final now = DateTime.now();
    if (cached != null &&
        cached.expiresAt.subtract(_signedUrlMargin).isAfter(now)) {
      return cached.url;
    }
    final url = await guardSupabase(
      () => _storage(
        () => client.storage
            .from(_photoBucket)
            .createSignedUrl(photoPath, _signedUrlLifetime.inSeconds),
      ),
    );
    _signedUrls[photoPath] = (url: url, expiresAt: now.add(_signedUrlLifetime));
    return url;
  }

  @override
  Future<List<AttendanceRecord>> history(
    String id,
    DateTime from,
    DateTime to,
  ) => guardSupabase(
    () async => _rows(
      await client.rpc<dynamic>(
        'trainee_attendance_history',
        params: {
          'p_trainee_id': id,
          'p_from': wireDate(from),
          'p_to': wireDate(to),
        },
      ),
    ).map(AttendanceRecord.fromJson).toList(),
  );

  Future<Trainee> _trainee(String function, Map<String, dynamic> params) =>
      guardSupabase(
        () async => Trainee.fromJson(
          _row(await client.rpc<dynamic>(function, params: params)),
        ),
      );

  // RFC 4122 version 4, so object names never collide across uploads.
  String _randomUuid() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final text = hex.join();
    return '${text.substring(0, 8)}-${text.substring(8, 12)}-'
        '${text.substring(12, 16)}-${text.substring(16, 20)}-'
        '${text.substring(20)}';
  }
}

Map<String, dynamic> _inputParams(TraineeInput input) {
  final dateOfBirth = input.dateOfBirth;
  final joinedOn = input.joinedOn;
  return {
    'p_full_name': input.fullName,
    'p_phone': input.phone,
    'p_date_of_birth': dateOfBirth == null ? null : wireDate(dateOfBirth),
    'p_joined_on': joinedOn == null ? null : wireDate(joinedOn),
    'p_notes': input.notes,
  };
}

// Storage refuses by HTTP status; the shared mapper only knows SQLSTATEs.
Future<T> _storage<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on StorageException catch (error) {
    throw switch (error.statusCode) {
      '401' || '403' => const PermissionException(),
      '413' => const ValidationException('The photo must be 2 MB or smaller'),
      _ => const UnknownException(),
    };
  }
}

// The bucket takes jpeg, png and webp; the picker re-encodes most photos as jpeg.
({String extension, String contentType}) _photoTypeOf(String fileName) {
  final name = fileName.toLowerCase();
  if (name.endsWith('.png')) {
    return (extension: 'png', contentType: 'image/png');
  }
  if (name.endsWith('.webp')) {
    return (extension: 'webp', contentType: 'image/webp');
  }
  return (extension: 'jpg', contentType: 'image/jpeg');
}

int _byName(Trainee a, Trainee b) {
  final byName = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
  return byName != 0 ? byName : a.id.compareTo(b.id);
}

// A set-returning function comes back as a JSON array of row objects.
List<Map<String, dynamic>> _rows(dynamic result) => [
  for (final row in result as List) Map<String, dynamic>.from(row as Map),
];

// A function returning one composite row comes back as a single JSON object.
Map<String, dynamic> _row(dynamic result) =>
    Map<String, dynamic>.from(result as Map);
