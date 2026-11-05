// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceRecord {

@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime get sessionDate;@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot get slot;@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) AttendanceStatus get status;@JsonKey(name: 'marked_at') DateTime get markedAt;/// `HH:mm:ss` India wall clock; null from a server older than the time columns.
@JsonKey(name: 'starts_at') String? get startsAt;@JsonKey(name: 'ends_at') String? get endsAt;
/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceRecordCopyWith<AttendanceRecord> get copyWith => _$AttendanceRecordCopyWithImpl<AttendanceRecord>(this as AttendanceRecord, _$identity);

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceRecord&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.sessionDate, _this.sessionDate) || other.sessionDate == _this.sessionDate)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.markedAt, _this.markedAt) || other.markedAt == _this.markedAt)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.endsAt, _this.endsAt) || other.endsAt == _this.endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceRecord;
  return Object.hash(runtimeType,_this.sessionId,_this.sessionDate,_this.slot,_this.status,_this.markedAt,_this.startsAt,_this.endsAt);
}

@override
String toString() {
  final _this = this as AttendanceRecord;
  return 'AttendanceRecord(sessionId: ${_this.sessionId}, sessionDate: ${_this.sessionDate}, slot: ${_this.slot}, status: ${_this.status}, markedAt: ${_this.markedAt}, startsAt: ${_this.startsAt}, endsAt: ${_this.endsAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceRecordCopyWith<$Res>  {
  factory $AttendanceRecordCopyWith(AttendanceRecord value, $Res Function(AttendanceRecord) _then) = _$AttendanceRecordCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime sessionDate,@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot slot,@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) AttendanceStatus status,@JsonKey(name: 'marked_at') DateTime markedAt,@JsonKey(name: 'starts_at') String? startsAt,@JsonKey(name: 'ends_at') String? endsAt
});




}
/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._self, this._then);

  final AttendanceRecord _self;
  final $Res Function(AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? sessionDate = null,Object? slot = null,Object? status = null,Object? markedAt = null,Object? startsAt = freezed,Object? endsAt = freezed,}) {
  return _then(AttendanceRecord(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceRecord].
extension AttendanceRecordPatterns on AttendanceRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceRecord value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceRecord value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)  AttendanceStatus status, @JsonKey(name: 'marked_at')  DateTime markedAt, @JsonKey(name: 'starts_at')  String? startsAt, @JsonKey(name: 'ends_at')  String? endsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.sessionId,_that.sessionDate,_that.slot,_that.status,_that.markedAt,_that.startsAt,_that.endsAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)  AttendanceStatus status, @JsonKey(name: 'marked_at')  DateTime markedAt, @JsonKey(name: 'starts_at')  String? startsAt, @JsonKey(name: 'ends_at')  String? endsAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord():
return $default(_that.sessionId,_that.sessionDate,_that.slot,_that.status,_that.markedAt,_that.startsAt,_that.endsAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)  AttendanceStatus status, @JsonKey(name: 'marked_at')  DateTime markedAt, @JsonKey(name: 'starts_at')  String? startsAt, @JsonKey(name: 'ends_at')  String? endsAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.sessionId,_that.sessionDate,_that.slot,_that.status,_that.markedAt,_that.startsAt,_that.endsAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceRecord implements AttendanceRecord {
  const _AttendanceRecord({@JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) required this.sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) required this.slot, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) required this.status, @JsonKey(name: 'marked_at') required this.markedAt, @JsonKey(name: 'starts_at') this.startsAt, @JsonKey(name: 'ends_at') this.endsAt});
  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) final  DateTime sessionDate;
@override@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) final  SessionSlot slot;
@override@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) final  AttendanceStatus status;
@override@JsonKey(name: 'marked_at') final  DateTime markedAt;
/// `HH:mm:ss` India wall clock; null from a server older than the time columns.
@override@JsonKey(name: 'starts_at') final  String? startsAt;
@override@JsonKey(name: 'ends_at') final  String? endsAt;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceRecordCopyWith<_AttendanceRecord> get copyWith => __$AttendanceRecordCopyWithImpl<_AttendanceRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceRecord&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.sessionDate, sessionDate) || other.sessionDate == sessionDate)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.status, status) || other.status == status)&&(identical(other.markedAt, markedAt) || other.markedAt == markedAt)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,sessionDate,slot,status,markedAt,startsAt,endsAt);
}

@override
String toString() {
    return 'AttendanceRecord(sessionId: $sessionId, sessionDate: $sessionDate, slot: $slot, status: $status, markedAt: $markedAt, startsAt: $startsAt, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceRecordCopyWith<$Res> implements $AttendanceRecordCopyWith<$Res> {
  factory _$AttendanceRecordCopyWith(_AttendanceRecord value, $Res Function(_AttendanceRecord) _then) = __$AttendanceRecordCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime sessionDate,@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot slot,@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) AttendanceStatus status,@JsonKey(name: 'marked_at') DateTime markedAt,@JsonKey(name: 'starts_at') String? startsAt,@JsonKey(name: 'ends_at') String? endsAt
});




}
/// @nodoc
class __$AttendanceRecordCopyWithImpl<$Res>
    implements _$AttendanceRecordCopyWith<$Res> {
  __$AttendanceRecordCopyWithImpl(this._self, this._then);

  final _AttendanceRecord _self;
  final $Res Function(_AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? sessionDate = null,Object? slot = null,Object? status = null,Object? markedAt = null,Object? startsAt = freezed,Object? endsAt = freezed,}) {
  return _then(_AttendanceRecord(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
