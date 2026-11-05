// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainee_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TraineeInput {

 String get fullName; String? get phone; DateTime? get dateOfBirth; DateTime? get joinedOn; String? get notes;
/// Create a copy of TraineeInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraineeInputCopyWith<TraineeInput> get copyWith => _$TraineeInputCopyWithImpl<TraineeInput>(this as TraineeInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TraineeInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraineeInput&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.dateOfBirth, _this.dateOfBirth) || other.dateOfBirth == _this.dateOfBirth)&&(identical(other.joinedOn, _this.joinedOn) || other.joinedOn == _this.joinedOn)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}


@override
int get hashCode {
  final _this = this as TraineeInput;
  return Object.hash(runtimeType,_this.fullName,_this.phone,_this.dateOfBirth,_this.joinedOn,_this.notes);
}

@override
String toString() {
  final _this = this as TraineeInput;
  return 'TraineeInput(fullName: ${_this.fullName}, phone: ${_this.phone}, dateOfBirth: ${_this.dateOfBirth}, joinedOn: ${_this.joinedOn}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $TraineeInputCopyWith<$Res>  {
  factory $TraineeInputCopyWith(TraineeInput value, $Res Function(TraineeInput) _then) = _$TraineeInputCopyWithImpl;
@useResult
$Res call({
 String fullName, String? phone, DateTime? dateOfBirth, DateTime? joinedOn, String? notes
});




}
/// @nodoc
class _$TraineeInputCopyWithImpl<$Res>
    implements $TraineeInputCopyWith<$Res> {
  _$TraineeInputCopyWithImpl(this._self, this._then);

  final TraineeInput _self;
  final $Res Function(TraineeInput) _then;

/// Create a copy of TraineeInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phone = freezed,Object? dateOfBirth = freezed,Object? joinedOn = freezed,Object? notes = freezed,}) {
  return _then(TraineeInput(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedOn: freezed == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TraineeInput].
extension TraineeInputPatterns on TraineeInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TraineeInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TraineeInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TraineeInput value)  $default,){
final _that = this;
switch (_that) {
case _TraineeInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TraineeInput value)?  $default,){
final _that = this;
switch (_that) {
case _TraineeInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String? phone,  DateTime? dateOfBirth,  DateTime? joinedOn,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TraineeInput() when $default != null:
return $default(_that.fullName,_that.phone,_that.dateOfBirth,_that.joinedOn,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String? phone,  DateTime? dateOfBirth,  DateTime? joinedOn,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _TraineeInput():
return $default(_that.fullName,_that.phone,_that.dateOfBirth,_that.joinedOn,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String? phone,  DateTime? dateOfBirth,  DateTime? joinedOn,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _TraineeInput() when $default != null:
return $default(_that.fullName,_that.phone,_that.dateOfBirth,_that.joinedOn,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _TraineeInput implements TraineeInput {
  const _TraineeInput({required this.fullName, this.phone, this.dateOfBirth, this.joinedOn, this.notes});
  

@override final  String fullName;
@override final  String? phone;
@override final  DateTime? dateOfBirth;
@override final  DateTime? joinedOn;
@override final  String? notes;

/// Create a copy of TraineeInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraineeInputCopyWith<_TraineeInput> get copyWith => __$TraineeInputCopyWithImpl<_TraineeInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraineeInput&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.joinedOn, joinedOn) || other.joinedOn == joinedOn)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,fullName,phone,dateOfBirth,joinedOn,notes);
}

@override
String toString() {
    return 'TraineeInput(fullName: $fullName, phone: $phone, dateOfBirth: $dateOfBirth, joinedOn: $joinedOn, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$TraineeInputCopyWith<$Res> implements $TraineeInputCopyWith<$Res> {
  factory _$TraineeInputCopyWith(_TraineeInput value, $Res Function(_TraineeInput) _then) = __$TraineeInputCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String? phone, DateTime? dateOfBirth, DateTime? joinedOn, String? notes
});




}
/// @nodoc
class __$TraineeInputCopyWithImpl<$Res>
    implements _$TraineeInputCopyWith<$Res> {
  __$TraineeInputCopyWithImpl(this._self, this._then);

  final _TraineeInput _self;
  final $Res Function(_TraineeInput) _then;

/// Create a copy of TraineeInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phone = freezed,Object? dateOfBirth = freezed,Object? joinedOn = freezed,Object? notes = freezed,}) {
  return _then(_TraineeInput(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedOn: freezed == joinedOn ? _self.joinedOn : joinedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
