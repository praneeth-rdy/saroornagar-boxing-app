// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'roster_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RosterEntry {

@JsonKey(name: 'trainee_id') String get traineeId;@JsonKey(name: 'roll_no') int get rollNo;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'photo_path') String? get photoPath;/// Null while the trainee is not marked for the session.
@JsonKey(fromJson: _statusFromWire, toJson: _statusToWire) AttendanceStatus? get status;@JsonKey(name: 'marked_at') DateTime? get markedAt;
/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RosterEntryCopyWith<RosterEntry> get copyWith => _$RosterEntryCopyWithImpl<RosterEntry>(this as RosterEntry, _$identity);

  /// Serializes this RosterEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RosterEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RosterEntry&&(identical(other.traineeId, _this.traineeId) || other.traineeId == _this.traineeId)&&(identical(other.rollNo, _this.rollNo) || other.rollNo == _this.rollNo)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.photoPath, _this.photoPath) || other.photoPath == _this.photoPath)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.markedAt, _this.markedAt) || other.markedAt == _this.markedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RosterEntry;
  return Object.hash(runtimeType,_this.traineeId,_this.rollNo,_this.fullName,_this.photoPath,_this.status,_this.markedAt);
}

@override
String toString() {
  final _this = this as RosterEntry;
  return 'RosterEntry(traineeId: ${_this.traineeId}, rollNo: ${_this.rollNo}, fullName: ${_this.fullName}, photoPath: ${_this.photoPath}, status: ${_this.status}, markedAt: ${_this.markedAt})';
}


}

/// @nodoc
abstract mixin class $RosterEntryCopyWith<$Res>  {
  factory $RosterEntryCopyWith(RosterEntry value, $Res Function(RosterEntry) _then) = _$RosterEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(name: 'roll_no') int rollNo,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(fromJson: _statusFromWire, toJson: _statusToWire) AttendanceStatus? status,@JsonKey(name: 'marked_at') DateTime? markedAt
});




}
/// @nodoc
class _$RosterEntryCopyWithImpl<$Res>
    implements $RosterEntryCopyWith<$Res> {
  _$RosterEntryCopyWithImpl(this._self, this._then);

  final RosterEntry _self;
  final $Res Function(RosterEntry) _then;

/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? traineeId = null,Object? rollNo = null,Object? fullName = null,Object? photoPath = freezed,Object? status = freezed,Object? markedAt = freezed,}) {
  return _then(RosterEntry(
traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,rollNo: null == rollNo ? _self.rollNo : rollNo // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus?,markedAt: freezed == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RosterEntry].
extension RosterEntryPatterns on RosterEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RosterEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RosterEntry value)  $default,){
final _that = this;
switch (_that) {
case _RosterEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RosterEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'roll_no')  int rollNo, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(fromJson: _statusFromWire, toJson: _statusToWire)  AttendanceStatus? status, @JsonKey(name: 'marked_at')  DateTime? markedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
return $default(_that.traineeId,_that.rollNo,_that.fullName,_that.photoPath,_that.status,_that.markedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'roll_no')  int rollNo, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(fromJson: _statusFromWire, toJson: _statusToWire)  AttendanceStatus? status, @JsonKey(name: 'marked_at')  DateTime? markedAt)  $default,) {final _that = this;
switch (_that) {
case _RosterEntry():
return $default(_that.traineeId,_that.rollNo,_that.fullName,_that.photoPath,_that.status,_that.markedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'roll_no')  int rollNo, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(fromJson: _statusFromWire, toJson: _statusToWire)  AttendanceStatus? status, @JsonKey(name: 'marked_at')  DateTime? markedAt)?  $default,) {final _that = this;
switch (_that) {
case _RosterEntry() when $default != null:
return $default(_that.traineeId,_that.rollNo,_that.fullName,_that.photoPath,_that.status,_that.markedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RosterEntry implements RosterEntry {
  const _RosterEntry({@JsonKey(name: 'trainee_id') required this.traineeId, @JsonKey(name: 'roll_no') required this.rollNo, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'photo_path') this.photoPath, @JsonKey(fromJson: _statusFromWire, toJson: _statusToWire) this.status, @JsonKey(name: 'marked_at') this.markedAt});
  factory _RosterEntry.fromJson(Map<String, dynamic> json) => _$RosterEntryFromJson(json);

@override@JsonKey(name: 'trainee_id') final  String traineeId;
@override@JsonKey(name: 'roll_no') final  int rollNo;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'photo_path') final  String? photoPath;
/// Null while the trainee is not marked for the session.
@override@JsonKey(fromJson: _statusFromWire, toJson: _statusToWire) final  AttendanceStatus? status;
@override@JsonKey(name: 'marked_at') final  DateTime? markedAt;

/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RosterEntryCopyWith<_RosterEntry> get copyWith => __$RosterEntryCopyWithImpl<_RosterEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RosterEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RosterEntry&&(identical(other.traineeId, traineeId) || other.traineeId == traineeId)&&(identical(other.rollNo, rollNo) || other.rollNo == rollNo)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.markedAt, markedAt) || other.markedAt == markedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,traineeId,rollNo,fullName,photoPath,status,markedAt);
}

@override
String toString() {
    return 'RosterEntry(traineeId: $traineeId, rollNo: $rollNo, fullName: $fullName, photoPath: $photoPath, status: $status, markedAt: $markedAt)';
}


}

/// @nodoc
abstract mixin class _$RosterEntryCopyWith<$Res> implements $RosterEntryCopyWith<$Res> {
  factory _$RosterEntryCopyWith(_RosterEntry value, $Res Function(_RosterEntry) _then) = __$RosterEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(name: 'roll_no') int rollNo,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(fromJson: _statusFromWire, toJson: _statusToWire) AttendanceStatus? status,@JsonKey(name: 'marked_at') DateTime? markedAt
});




}
/// @nodoc
class __$RosterEntryCopyWithImpl<$Res>
    implements _$RosterEntryCopyWith<$Res> {
  __$RosterEntryCopyWithImpl(this._self, this._then);

  final _RosterEntry _self;
  final $Res Function(_RosterEntry) _then;

/// Create a copy of RosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? traineeId = null,Object? rollNo = null,Object? fullName = null,Object? photoPath = freezed,Object? status = freezed,Object? markedAt = freezed,}) {
  return _then(_RosterEntry(
traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,rollNo: null == rollNo ? _self.rollNo : rollNo // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus?,markedAt: freezed == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
