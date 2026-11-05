// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffProfile {

 String get id;@JsonKey(name: 'full_name') String get fullName; String get phone;@JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire) StaffRole get role;@JsonKey(name: 'is_blocked') bool get isBlocked;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffProfileCopyWith<StaffProfile> get copyWith => _$StaffProfileCopyWithImpl<StaffProfile>(this as StaffProfile, _$identity);

  /// Serializes this StaffProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StaffProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isBlocked, _this.isBlocked) || other.isBlocked == _this.isBlocked)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StaffProfile;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.phone,_this.role,_this.isBlocked,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as StaffProfile;
  return 'StaffProfile(id: ${_this.id}, fullName: ${_this.fullName}, phone: ${_this.phone}, role: ${_this.role}, isBlocked: ${_this.isBlocked}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $StaffProfileCopyWith<$Res>  {
  factory $StaffProfileCopyWith(StaffProfile value, $Res Function(StaffProfile) _then) = _$StaffProfileCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone,@JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire) StaffRole role,@JsonKey(name: 'is_blocked') bool isBlocked,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$StaffProfileCopyWithImpl<$Res>
    implements $StaffProfileCopyWith<$Res> {
  _$StaffProfileCopyWithImpl(this._self, this._then);

  final StaffProfile _self;
  final $Res Function(StaffProfile) _then;

/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? role = null,Object? isBlocked = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(StaffProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffProfile].
extension StaffProfilePatterns on StaffProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffProfile value)  $default,){
final _that = this;
switch (_that) {
case _StaffProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffProfile value)?  $default,){
final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone, @JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire)  StaffRole role, @JsonKey(name: 'is_blocked')  bool isBlocked, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.role,_that.isBlocked,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone, @JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire)  StaffRole role, @JsonKey(name: 'is_blocked')  bool isBlocked, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StaffProfile():
return $default(_that.id,_that.fullName,_that.phone,_that.role,_that.isBlocked,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone, @JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire)  StaffRole role, @JsonKey(name: 'is_blocked')  bool isBlocked, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.role,_that.isBlocked,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffProfile extends StaffProfile {
  const _StaffProfile({required this.id, @JsonKey(name: 'full_name') required this.fullName, required this.phone, @JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire) required this.role, @JsonKey(name: 'is_blocked') required this.isBlocked, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): super._();
  factory _StaffProfile.fromJson(Map<String, dynamic> json) => _$StaffProfileFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String phone;
@override@JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire) final  StaffRole role;
@override@JsonKey(name: 'is_blocked') final  bool isBlocked;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffProfileCopyWith<_StaffProfile> get copyWith => __$StaffProfileCopyWithImpl<_StaffProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,phone,role,isBlocked,createdAt,updatedAt);
}

@override
String toString() {
    return 'StaffProfile(id: $id, fullName: $fullName, phone: $phone, role: $role, isBlocked: $isBlocked, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StaffProfileCopyWith<$Res> implements $StaffProfileCopyWith<$Res> {
  factory _$StaffProfileCopyWith(_StaffProfile value, $Res Function(_StaffProfile) _then) = __$StaffProfileCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone,@JsonKey(fromJson: StaffRole.fromWire, toJson: _roleToWire) StaffRole role,@JsonKey(name: 'is_blocked') bool isBlocked,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$StaffProfileCopyWithImpl<$Res>
    implements _$StaffProfileCopyWith<$Res> {
  __$StaffProfileCopyWithImpl(this._self, this._then);

  final _StaffProfile _self;
  final $Res Function(_StaffProfile) _then;

/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? role = null,Object? isBlocked = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_StaffProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
