// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffInput {

 String get fullName; StaffRole get role; String? get email;/// Optional; blank or null means no phone.
 String? get phone; String? get password;
/// Create a copy of StaffInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffInputCopyWith<StaffInput> get copyWith => _$StaffInputCopyWithImpl<StaffInput>(this as StaffInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StaffInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffInput&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.password, _this.password) || other.password == _this.password));
}


@override
int get hashCode {
  final _this = this as StaffInput;
  return Object.hash(runtimeType,_this.fullName,_this.role,_this.email,_this.phone,_this.password);
}

@override
String toString() {
  final _this = this as StaffInput;
  return 'StaffInput(fullName: ${_this.fullName}, role: ${_this.role}, email: ${_this.email}, phone: ${_this.phone}, password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $StaffInputCopyWith<$Res>  {
  factory $StaffInputCopyWith(StaffInput value, $Res Function(StaffInput) _then) = _$StaffInputCopyWithImpl;
@useResult
$Res call({
 String fullName, StaffRole role, String? email, String? phone, String? password
});




}
/// @nodoc
class _$StaffInputCopyWithImpl<$Res>
    implements $StaffInputCopyWith<$Res> {
  _$StaffInputCopyWithImpl(this._self, this._then);

  final StaffInput _self;
  final $Res Function(StaffInput) _then;

/// Create a copy of StaffInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? role = null,Object? email = freezed,Object? phone = freezed,Object? password = freezed,}) {
  return _then(StaffInput(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffInput].
extension StaffInputPatterns on StaffInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffInput value)  $default,){
final _that = this;
switch (_that) {
case _StaffInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffInput value)?  $default,){
final _that = this;
switch (_that) {
case _StaffInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  StaffRole role,  String? email,  String? phone,  String? password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffInput() when $default != null:
return $default(_that.fullName,_that.role,_that.email,_that.phone,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  StaffRole role,  String? email,  String? phone,  String? password)  $default,) {final _that = this;
switch (_that) {
case _StaffInput():
return $default(_that.fullName,_that.role,_that.email,_that.phone,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  StaffRole role,  String? email,  String? phone,  String? password)?  $default,) {final _that = this;
switch (_that) {
case _StaffInput() when $default != null:
return $default(_that.fullName,_that.role,_that.email,_that.phone,_that.password);case _:
  return null;

}
}

}

/// @nodoc


class _StaffInput implements StaffInput {
  const _StaffInput({required this.fullName, required this.role, this.email, this.phone, this.password});
  

@override final  String fullName;
@override final  StaffRole role;
@override final  String? email;
/// Optional; blank or null means no phone.
@override final  String? phone;
@override final  String? password;

/// Create a copy of StaffInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffInputCopyWith<_StaffInput> get copyWith => __$StaffInputCopyWithImpl<_StaffInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffInput&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode {
    return Object.hash(runtimeType,fullName,role,email,phone,password);
}

@override
String toString() {
    return 'StaffInput(fullName: $fullName, role: $role, email: $email, phone: $phone, password: $password)';
}


}

/// @nodoc
abstract mixin class _$StaffInputCopyWith<$Res> implements $StaffInputCopyWith<$Res> {
  factory _$StaffInputCopyWith(_StaffInput value, $Res Function(_StaffInput) _then) = __$StaffInputCopyWithImpl;
@override @useResult
$Res call({
 String fullName, StaffRole role, String? email, String? phone, String? password
});




}
/// @nodoc
class __$StaffInputCopyWithImpl<$Res>
    implements _$StaffInputCopyWith<$Res> {
  __$StaffInputCopyWithImpl(this._self, this._then);

  final _StaffInput _self;
  final $Res Function(_StaffInput) _then;

/// Create a copy of StaffInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? role = null,Object? email = freezed,Object? phone = freezed,Object? password = freezed,}) {
  return _then(_StaffInput(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
