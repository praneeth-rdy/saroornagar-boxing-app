// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trainee {

 String get id;/// Called out at roll call; unique among active students, so an inactive one's may be reused.
@JsonKey(name: 'roll_no') int get rollNo;@JsonKey(name: 'full_name') String get fullName;/// Stored as `91XXXXXXXXXX`.
 String? get phone;/// Object name in the `trainee-photos` bucket, not a URL.
@JsonKey(name: 'photo_path') String? get photoPath;@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? get dateOfBirth;@JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? get joinedOn;@JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire) TraineeStatus get status; String? get notes;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Trainee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraineeCopyWith<Trainee> get copyWith => _$TraineeCopyWithImpl<Trainee>(this as Trainee, _$identity);

  /// Serializes this Trainee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Trainee;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trainee&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rollNo, _this.rollNo) || other.rollNo == _this.rollNo)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.photoPath, _this.photoPath) || other.photoPath == _this.photoPath)&&(identical(other.dateOfBirth, _this.dateOfBirth) || other.dateOfBirth == _this.dateOfBirth)&&(identical(other.joinedOn, _this.joinedOn) || other.joinedOn == _this.joinedOn)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Trainee;
  return Object.hash(runtimeType,_this.id,_this.rollNo,_this.fullName,_this.phone,_this.photoPath,_this.dateOfBirth,_this.joinedOn,_this.status,_this.notes,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Trainee;
  return 'Trainee(id: ${_this.id}, rollNo: ${_this.rollNo}, fullName: ${_this.fullName}, phone: ${_this.phone}, photoPath: ${_this.photoPath}, dateOfBirth: ${_this.dateOfBirth}, joinedOn: ${_this.joinedOn}, status: ${_this.status}, notes: ${_this.notes}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $TraineeCopyWith<$Res>  {
  factory $TraineeCopyWith(Trainee value, $Res Function(Trainee) _then) = _$TraineeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'roll_no') int rollNo,@JsonKey(name: 'full_name') String fullName, String? phone,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? dateOfBirth,@JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? joinedOn,@JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire) TraineeStatus status, String? notes,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$TraineeCopyWithImpl<$Res>
    implements $TraineeCopyWith<$Res> {
  _$TraineeCopyWithImpl(this._self, this._then);

  final Trainee _self;
  final $Res Function(Trainee) _then;

/// Create a copy of Trainee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rollNo = null,Object? fullName = null,Object? phone = freezed,Object? photoPath = freezed,Object? dateOfBirth = freezed,Object? joinedOn = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Trainee(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rollNo: null == rollNo ? _self.rollNo : rollNo // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedOn: freezed == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TraineeStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Trainee].
extension TraineePatterns on Trainee {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trainee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trainee() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trainee value)  $default,){
final _that = this;
switch (_that) {
case _Trainee():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trainee value)?  $default,){
final _that = this;
switch (_that) {
case _Trainee() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'roll_no')  int rollNo, @JsonKey(name: 'full_name')  String fullName,  String? phone, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? dateOfBirth, @JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? joinedOn, @JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire)  TraineeStatus status,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trainee() when $default != null:
return $default(_that.id,_that.rollNo,_that.fullName,_that.phone,_that.photoPath,_that.dateOfBirth,_that.joinedOn,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'roll_no')  int rollNo, @JsonKey(name: 'full_name')  String fullName,  String? phone, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? dateOfBirth, @JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? joinedOn, @JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire)  TraineeStatus status,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Trainee():
return $default(_that.id,_that.rollNo,_that.fullName,_that.phone,_that.photoPath,_that.dateOfBirth,_that.joinedOn,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'roll_no')  int rollNo, @JsonKey(name: 'full_name')  String fullName,  String? phone, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? dateOfBirth, @JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? joinedOn, @JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire)  TraineeStatus status,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Trainee() when $default != null:
return $default(_that.id,_that.rollNo,_that.fullName,_that.phone,_that.photoPath,_that.dateOfBirth,_that.joinedOn,_that.status,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trainee extends Trainee {
  const _Trainee({required this.id, @JsonKey(name: 'roll_no') required this.rollNo, @JsonKey(name: 'full_name') required this.fullName, this.phone, @JsonKey(name: 'photo_path') this.photoPath, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) this.dateOfBirth, @JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) this.joinedOn, @JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire) required this.status, this.notes, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): super._();
  factory _Trainee.fromJson(Map<String, dynamic> json) => _$TraineeFromJson(json);

@override final  String id;
/// Called out at roll call; unique among active students, so an inactive one's may be reused.
@override@JsonKey(name: 'roll_no') final  int rollNo;
@override@JsonKey(name: 'full_name') final  String fullName;
/// Stored as `91XXXXXXXXXX`.
@override final  String? phone;
/// Object name in the `trainee-photos` bucket, not a URL.
@override@JsonKey(name: 'photo_path') final  String? photoPath;
@override@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) final  DateTime? dateOfBirth;
@override@JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) final  DateTime? joinedOn;
@override@JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire) final  TraineeStatus status;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Trainee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraineeCopyWith<_Trainee> get copyWith => __$TraineeCopyWithImpl<_Trainee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraineeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trainee&&(identical(other.id, id) || other.id == id)&&(identical(other.rollNo, rollNo) || other.rollNo == rollNo)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,rollNo,fullName,phone,photoPath,dateOfBirth,joinedOn,status,notes,createdAt,updatedAt);
}

@override
String toString() {
    return 'Trainee(id: $id, rollNo: $rollNo, fullName: $fullName, phone: $phone, photoPath: $photoPath, dateOfBirth: $dateOfBirth, joinedOn: $joinedOn, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TraineeCopyWith<$Res> implements $TraineeCopyWith<$Res> {
  factory _$TraineeCopyWith(_Trainee value, $Res Function(_Trainee) _then) = __$TraineeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'roll_no') int rollNo,@JsonKey(name: 'full_name') String fullName, String? phone,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? dateOfBirth,@JsonKey(name: 'joined_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? joinedOn,@JsonKey(fromJson: TraineeStatus.fromWire, toJson: _statusToWire) TraineeStatus status, String? notes,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$TraineeCopyWithImpl<$Res>
    implements _$TraineeCopyWith<$Res> {
  __$TraineeCopyWithImpl(this._self, this._then);

  final _Trainee _self;
  final $Res Function(_Trainee) _then;

/// Create a copy of Trainee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rollNo = null,Object? fullName = null,Object? phone = freezed,Object? photoPath = freezed,Object? dateOfBirth = freezed,Object? joinedOn = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Trainee(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rollNo: null == rollNo ? _self.rollNo : rollNo // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedOn: freezed == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TraineeStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
