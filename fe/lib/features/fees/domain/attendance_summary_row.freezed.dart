// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_summary_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceSummaryRow {

@JsonKey(name: 'trainee_id') String get traineeId;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'photo_path') String? get photoPath;@JsonKey(name: 'present_count') int get presentCount;@JsonKey(name: 'absent_count') int get absentCount;/// Sessions dated in the month; the same on every row.
@JsonKey(name: 'session_count') int get sessionCount;
/// Create a copy of AttendanceSummaryRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceSummaryRowCopyWith<AttendanceSummaryRow> get copyWith => _$AttendanceSummaryRowCopyWithImpl<AttendanceSummaryRow>(this as AttendanceSummaryRow, _$identity);

  /// Serializes this AttendanceSummaryRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttendanceSummaryRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceSummaryRow&&(identical(other.traineeId, _this.traineeId) || other.traineeId == _this.traineeId)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.photoPath, _this.photoPath) || other.photoPath == _this.photoPath)&&(identical(other.presentCount, _this.presentCount) || other.presentCount == _this.presentCount)&&(identical(other.absentCount, _this.absentCount) || other.absentCount == _this.absentCount)&&(identical(other.sessionCount, _this.sessionCount) || other.sessionCount == _this.sessionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttendanceSummaryRow;
  return Object.hash(runtimeType,_this.traineeId,_this.fullName,_this.photoPath,_this.presentCount,_this.absentCount,_this.sessionCount);
}

@override
String toString() {
  final _this = this as AttendanceSummaryRow;
  return 'AttendanceSummaryRow(traineeId: ${_this.traineeId}, fullName: ${_this.fullName}, photoPath: ${_this.photoPath}, presentCount: ${_this.presentCount}, absentCount: ${_this.absentCount}, sessionCount: ${_this.sessionCount})';
}


}

/// @nodoc
abstract mixin class $AttendanceSummaryRowCopyWith<$Res>  {
  factory $AttendanceSummaryRowCopyWith(AttendanceSummaryRow value, $Res Function(AttendanceSummaryRow) _then) = _$AttendanceSummaryRowCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'present_count') int presentCount,@JsonKey(name: 'absent_count') int absentCount,@JsonKey(name: 'session_count') int sessionCount
});




}
/// @nodoc
class _$AttendanceSummaryRowCopyWithImpl<$Res>
    implements $AttendanceSummaryRowCopyWith<$Res> {
  _$AttendanceSummaryRowCopyWithImpl(this._self, this._then);

  final AttendanceSummaryRow _self;
  final $Res Function(AttendanceSummaryRow) _then;

/// Create a copy of AttendanceSummaryRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? traineeId = null,Object? fullName = null,Object? photoPath = freezed,Object? presentCount = null,Object? absentCount = null,Object? sessionCount = null,}) {
  return _then(AttendanceSummaryRow(
traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,presentCount: null == presentCount ? _self.presentCount : presentCount // ignore: cast_nullable_to_non_nullable
as int,absentCount: null == absentCount ? _self.absentCount : absentCount // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceSummaryRow].
extension AttendanceSummaryRowPatterns on AttendanceSummaryRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceSummaryRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceSummaryRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceSummaryRow value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceSummaryRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceSummaryRow value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceSummaryRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'present_count')  int presentCount, @JsonKey(name: 'absent_count')  int absentCount, @JsonKey(name: 'session_count')  int sessionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceSummaryRow() when $default != null:
return $default(_that.traineeId,_that.fullName,_that.photoPath,_that.presentCount,_that.absentCount,_that.sessionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'present_count')  int presentCount, @JsonKey(name: 'absent_count')  int absentCount, @JsonKey(name: 'session_count')  int sessionCount)  $default,) {final _that = this;
switch (_that) {
case _AttendanceSummaryRow():
return $default(_that.traineeId,_that.fullName,_that.photoPath,_that.presentCount,_that.absentCount,_that.sessionCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'present_count')  int presentCount, @JsonKey(name: 'absent_count')  int absentCount, @JsonKey(name: 'session_count')  int sessionCount)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceSummaryRow() when $default != null:
return $default(_that.traineeId,_that.fullName,_that.photoPath,_that.presentCount,_that.absentCount,_that.sessionCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceSummaryRow implements AttendanceSummaryRow {
  const _AttendanceSummaryRow({@JsonKey(name: 'trainee_id') required this.traineeId, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'photo_path') this.photoPath, @JsonKey(name: 'present_count') required this.presentCount, @JsonKey(name: 'absent_count') required this.absentCount, @JsonKey(name: 'session_count') required this.sessionCount});
  factory _AttendanceSummaryRow.fromJson(Map<String, dynamic> json) => _$AttendanceSummaryRowFromJson(json);

@override@JsonKey(name: 'trainee_id') final  String traineeId;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'photo_path') final  String? photoPath;
@override@JsonKey(name: 'present_count') final  int presentCount;
@override@JsonKey(name: 'absent_count') final  int absentCount;
/// Sessions dated in the month; the same on every row.
@override@JsonKey(name: 'session_count') final  int sessionCount;

/// Create a copy of AttendanceSummaryRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceSummaryRowCopyWith<_AttendanceSummaryRow> get copyWith => __$AttendanceSummaryRowCopyWithImpl<_AttendanceSummaryRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceSummaryRowToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceSummaryRow&&(identical(other.traineeId, traineeId) || other.traineeId == traineeId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.presentCount, presentCount) || other.presentCount == presentCount)&&(identical(other.absentCount, absentCount) || other.absentCount == absentCount)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,traineeId,fullName,photoPath,presentCount,absentCount,sessionCount);
}

@override
String toString() {
    return 'AttendanceSummaryRow(traineeId: $traineeId, fullName: $fullName, photoPath: $photoPath, presentCount: $presentCount, absentCount: $absentCount, sessionCount: $sessionCount)';
}


}

/// @nodoc
abstract mixin class _$AttendanceSummaryRowCopyWith<$Res> implements $AttendanceSummaryRowCopyWith<$Res> {
  factory _$AttendanceSummaryRowCopyWith(_AttendanceSummaryRow value, $Res Function(_AttendanceSummaryRow) _then) = __$AttendanceSummaryRowCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'present_count') int presentCount,@JsonKey(name: 'absent_count') int absentCount,@JsonKey(name: 'session_count') int sessionCount
});




}
/// @nodoc
class __$AttendanceSummaryRowCopyWithImpl<$Res>
    implements _$AttendanceSummaryRowCopyWith<$Res> {
  __$AttendanceSummaryRowCopyWithImpl(this._self, this._then);

  final _AttendanceSummaryRow _self;
  final $Res Function(_AttendanceSummaryRow) _then;

/// Create a copy of AttendanceSummaryRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? traineeId = null,Object? fullName = null,Object? photoPath = freezed,Object? presentCount = null,Object? absentCount = null,Object? sessionCount = null,}) {
  return _then(_AttendanceSummaryRow(
traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,presentCount: null == presentCount ? _self.presentCount : presentCount // ignore: cast_nullable_to_non_nullable
as int,absentCount: null == absentCount ? _self.absentCount : absentCount // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
