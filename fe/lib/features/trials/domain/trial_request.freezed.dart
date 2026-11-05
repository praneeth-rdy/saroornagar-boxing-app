// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trial_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrialRequest {

 String get fullName; String get phone; DateTime get sessionDate; SessionSlot get slot; DateTime? get dateOfBirth; int? get age; String? get note;
/// Create a copy of TrialRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrialRequestCopyWith<TrialRequest> get copyWith => _$TrialRequestCopyWithImpl<TrialRequest>(this as TrialRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrialRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrialRequest&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.sessionDate, _this.sessionDate) || other.sessionDate == _this.sessionDate)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&(identical(other.dateOfBirth, _this.dateOfBirth) || other.dateOfBirth == _this.dateOfBirth)&&(identical(other.age, _this.age) || other.age == _this.age)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as TrialRequest;
  return Object.hash(runtimeType,_this.fullName,_this.phone,_this.sessionDate,_this.slot,_this.dateOfBirth,_this.age,_this.note);
}

@override
String toString() {
  final _this = this as TrialRequest;
  return 'TrialRequest(fullName: ${_this.fullName}, phone: ${_this.phone}, sessionDate: ${_this.sessionDate}, slot: ${_this.slot}, dateOfBirth: ${_this.dateOfBirth}, age: ${_this.age}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $TrialRequestCopyWith<$Res>  {
  factory $TrialRequestCopyWith(TrialRequest value, $Res Function(TrialRequest) _then) = _$TrialRequestCopyWithImpl;
@useResult
$Res call({
 String fullName, String phone, DateTime sessionDate, SessionSlot slot, DateTime? dateOfBirth, int? age, String? note
});




}
/// @nodoc
class _$TrialRequestCopyWithImpl<$Res>
    implements $TrialRequestCopyWith<$Res> {
  _$TrialRequestCopyWithImpl(this._self, this._then);

  final TrialRequest _self;
  final $Res Function(TrialRequest) _then;

/// Create a copy of TrialRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phone = null,Object? sessionDate = null,Object? slot = null,Object? dateOfBirth = freezed,Object? age = freezed,Object? note = freezed,}) {
  return _then(TrialRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrialRequest].
extension TrialRequestPatterns on TrialRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrialRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrialRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrialRequest value)  $default,){
final _that = this;
switch (_that) {
case _TrialRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrialRequest value)?  $default,){
final _that = this;
switch (_that) {
case _TrialRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String phone,  DateTime sessionDate,  SessionSlot slot,  DateTime? dateOfBirth,  int? age,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrialRequest() when $default != null:
return $default(_that.fullName,_that.phone,_that.sessionDate,_that.slot,_that.dateOfBirth,_that.age,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String phone,  DateTime sessionDate,  SessionSlot slot,  DateTime? dateOfBirth,  int? age,  String? note)  $default,) {final _that = this;
switch (_that) {
case _TrialRequest():
return $default(_that.fullName,_that.phone,_that.sessionDate,_that.slot,_that.dateOfBirth,_that.age,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String phone,  DateTime sessionDate,  SessionSlot slot,  DateTime? dateOfBirth,  int? age,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _TrialRequest() when $default != null:
return $default(_that.fullName,_that.phone,_that.sessionDate,_that.slot,_that.dateOfBirth,_that.age,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _TrialRequest implements TrialRequest {
  const _TrialRequest({required this.fullName, required this.phone, required this.sessionDate, required this.slot, this.dateOfBirth, this.age, this.note});
  

@override final  String fullName;
@override final  String phone;
@override final  DateTime sessionDate;
@override final  SessionSlot slot;
@override final  DateTime? dateOfBirth;
@override final  int? age;
@override final  String? note;

/// Create a copy of TrialRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrialRequestCopyWith<_TrialRequest> get copyWith => __$TrialRequestCopyWithImpl<_TrialRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrialRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.sessionDate, sessionDate) || other.sessionDate == sessionDate)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.age, age) || other.age == age)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,fullName,phone,sessionDate,slot,dateOfBirth,age,note);
}

@override
String toString() {
    return 'TrialRequest(fullName: $fullName, phone: $phone, sessionDate: $sessionDate, slot: $slot, dateOfBirth: $dateOfBirth, age: $age, note: $note)';
}


}

/// @nodoc
abstract mixin class _$TrialRequestCopyWith<$Res> implements $TrialRequestCopyWith<$Res> {
  factory _$TrialRequestCopyWith(_TrialRequest value, $Res Function(_TrialRequest) _then) = __$TrialRequestCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String phone, DateTime sessionDate, SessionSlot slot, DateTime? dateOfBirth, int? age, String? note
});




}
/// @nodoc
class __$TrialRequestCopyWithImpl<$Res>
    implements _$TrialRequestCopyWith<$Res> {
  __$TrialRequestCopyWithImpl(this._self, this._then);

  final _TrialRequest _self;
  final $Res Function(_TrialRequest) _then;

/// Create a copy of TrialRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phone = null,Object? sessionDate = null,Object? slot = null,Object? dateOfBirth = freezed,Object? age = freezed,Object? note = freezed,}) {
  return _then(_TrialRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
