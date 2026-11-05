// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_mark.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceMark {

@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'trainee_id') String get traineeId;@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) AttendanceStatus get status;@JsonKey(name: 'marked_by') String? get markedBy;@JsonKey(name: 'marked_at') DateTime get markedAt;
/// Create a copy of AttendanceMark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceMarkCopyWith<AttendanceMark> get copyWith => _$AttendanceMarkCopyWithImpl<AttendanceMark>(this as AttendanceMark, _$identity);

  /// Serializes this AttendanceMark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceMark;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceMark&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.traineeId, _this.traineeId) || other.traineeId == _this.traineeId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.markedBy, _this.markedBy) || other.markedBy == _this.markedBy)&&(identical(other.markedAt, _this.markedAt) || other.markedAt == _this.markedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceMark;
  return Object.hash(runtimeType,_this.sessionId,_this.traineeId,_this.status,_this.markedBy,_this.markedAt);
}

@override
String toString() {
  final _this = this as AttendanceMark;
  return 'AttendanceMark(sessionId: ${_this.sessionId}, traineeId: ${_this.traineeId}, status: ${_this.status}, markedBy: ${_this.markedBy}, markedAt: ${_this.markedAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceMarkCopyWith<$Res>  {
  factory $AttendanceMarkCopyWith(AttendanceMark value, $Res Function(AttendanceMark) _then) = _$AttendanceMarkCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) AttendanceStatus status,@JsonKey(name: 'marked_by') String? markedBy,@JsonKey(name: 'marked_at') DateTime markedAt
});




}
/// @nodoc
class _$AttendanceMarkCopyWithImpl<$Res>
    implements $AttendanceMarkCopyWith<$Res> {
  _$AttendanceMarkCopyWithImpl(this._self, this._then);

  final AttendanceMark _self;
  final $Res Function(AttendanceMark) _then;

/// Create a copy of AttendanceMark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? traineeId = null,Object? status = null,Object? markedBy = freezed,Object? markedAt = null,}) {
  return _then(AttendanceMark(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,markedBy: freezed == markedBy ? _self.markedBy : markedBy // ignore: cast_nullable_to_non_nullable
as String?,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceMark].
extension AttendanceMarkPatterns on AttendanceMark {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceMark value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceMark() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceMark value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceMark():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceMark value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceMark() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)  AttendanceStatus status, @JsonKey(name: 'marked_by')  String? markedBy, @JsonKey(name: 'marked_at')  DateTime markedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceMark() when $default != null:
return $default(_that.sessionId,_that.traineeId,_that.status,_that.markedBy,_that.markedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)  AttendanceStatus status, @JsonKey(name: 'marked_by')  String? markedBy, @JsonKey(name: 'marked_at')  DateTime markedAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceMark():
return $default(_that.sessionId,_that.traineeId,_that.status,_that.markedBy,_that.markedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire)  AttendanceStatus status, @JsonKey(name: 'marked_by')  String? markedBy, @JsonKey(name: 'marked_at')  DateTime markedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceMark() when $default != null:
return $default(_that.sessionId,_that.traineeId,_that.status,_that.markedBy,_that.markedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceMark implements AttendanceMark {
  const _AttendanceMark({@JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'trainee_id') required this.traineeId, @JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) required this.status, @JsonKey(name: 'marked_by') this.markedBy, @JsonKey(name: 'marked_at') required this.markedAt});
  factory _AttendanceMark.fromJson(Map<String, dynamic> json) => _$AttendanceMarkFromJson(json);

@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'trainee_id') final  String traineeId;
@override@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) final  AttendanceStatus status;
@override@JsonKey(name: 'marked_by') final  String? markedBy;
@override@JsonKey(name: 'marked_at') final  DateTime markedAt;

/// Create a copy of AttendanceMark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceMarkCopyWith<_AttendanceMark> get copyWith => __$AttendanceMarkCopyWithImpl<_AttendanceMark>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceMarkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceMark&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.traineeId, traineeId) || other.traineeId == traineeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.markedBy, markedBy) || other.markedBy == markedBy)&&(identical(other.markedAt, markedAt) || other.markedAt == markedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,traineeId,status,markedBy,markedAt);
}

@override
String toString() {
    return 'AttendanceMark(sessionId: $sessionId, traineeId: $traineeId, status: $status, markedBy: $markedBy, markedAt: $markedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceMarkCopyWith<$Res> implements $AttendanceMarkCopyWith<$Res> {
  factory _$AttendanceMarkCopyWith(_AttendanceMark value, $Res Function(_AttendanceMark) _then) = __$AttendanceMarkCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(fromJson: AttendanceStatus.fromWire, toJson: _statusToWire) AttendanceStatus status,@JsonKey(name: 'marked_by') String? markedBy,@JsonKey(name: 'marked_at') DateTime markedAt
});




}
/// @nodoc
class __$AttendanceMarkCopyWithImpl<$Res>
    implements _$AttendanceMarkCopyWith<$Res> {
  __$AttendanceMarkCopyWithImpl(this._self, this._then);

  final _AttendanceMark _self;
  final $Res Function(_AttendanceMark) _then;

/// Create a copy of AttendanceMark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? traineeId = null,Object? status = null,Object? markedBy = freezed,Object? markedAt = null,}) {
  return _then(_AttendanceMark(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,markedBy: freezed == markedBy ? _self.markedBy : markedBy // ignore: cast_nullable_to_non_nullable
as String?,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
