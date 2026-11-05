// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trial_booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrialBooking {

 String get id;@JsonKey(name: 'full_name') String get fullName; String get phone;@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? get dateOfBirth; int? get age;@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime get sessionDate;@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot get slot; String? get note;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of TrialBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrialBookingCopyWith<TrialBooking> get copyWith => _$TrialBookingCopyWithImpl<TrialBooking>(this as TrialBooking, _$identity);

  /// Serializes this TrialBooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrialBooking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrialBooking&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.dateOfBirth, _this.dateOfBirth) || other.dateOfBirth == _this.dateOfBirth)&&(identical(other.age, _this.age) || other.age == _this.age)&&(identical(other.sessionDate, _this.sessionDate) || other.sessionDate == _this.sessionDate)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrialBooking;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.phone,_this.dateOfBirth,_this.age,_this.sessionDate,_this.slot,_this.note,_this.createdAt);
}

@override
String toString() {
  final _this = this as TrialBooking;
  return 'TrialBooking(id: ${_this.id}, fullName: ${_this.fullName}, phone: ${_this.phone}, dateOfBirth: ${_this.dateOfBirth}, age: ${_this.age}, sessionDate: ${_this.sessionDate}, slot: ${_this.slot}, note: ${_this.note}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $TrialBookingCopyWith<$Res>  {
  factory $TrialBookingCopyWith(TrialBooking value, $Res Function(TrialBooking) _then) = _$TrialBookingCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone,@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? dateOfBirth, int? age,@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime sessionDate,@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot slot, String? note,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$TrialBookingCopyWithImpl<$Res>
    implements $TrialBookingCopyWith<$Res> {
  _$TrialBookingCopyWithImpl(this._self, this._then);

  final TrialBooking _self;
  final $Res Function(TrialBooking) _then;

/// Create a copy of TrialBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? dateOfBirth = freezed,Object? age = freezed,Object? sessionDate = null,Object? slot = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(TrialBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrialBooking].
extension TrialBookingPatterns on TrialBooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrialBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrialBooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrialBooking value)  $default,){
final _that = this;
switch (_that) {
case _TrialBooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrialBooking value)?  $default,){
final _that = this;
switch (_that) {
case _TrialBooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? dateOfBirth,  int? age, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot,  String? note, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrialBooking() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.dateOfBirth,_that.age,_that.sessionDate,_that.slot,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? dateOfBirth,  int? age, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot,  String? note, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrialBooking():
return $default(_that.id,_that.fullName,_that.phone,_that.dateOfBirth,_that.age,_that.sessionDate,_that.slot,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? dateOfBirth,  int? age, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot,  String? note, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrialBooking() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.dateOfBirth,_that.age,_that.sessionDate,_that.slot,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrialBooking implements TrialBooking {
  const _TrialBooking({required this.id, @JsonKey(name: 'full_name') required this.fullName, required this.phone, @JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) this.dateOfBirth, this.age, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) required this.sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) required this.slot, this.note, @JsonKey(name: 'created_at') required this.createdAt});
  factory _TrialBooking.fromJson(Map<String, dynamic> json) => _$TrialBookingFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String phone;
@override@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) final  DateTime? dateOfBirth;
@override final  int? age;
@override@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) final  DateTime sessionDate;
@override@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) final  SessionSlot slot;
@override final  String? note;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of TrialBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrialBookingCopyWith<_TrialBooking> get copyWith => __$TrialBookingCopyWithImpl<_TrialBooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrialBookingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrialBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.age, age) || other.age == age)&&(identical(other.sessionDate, sessionDate) || other.sessionDate == sessionDate)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,phone,dateOfBirth,age,sessionDate,slot,note,createdAt);
}

@override
String toString() {
    return 'TrialBooking(id: $id, fullName: $fullName, phone: $phone, dateOfBirth: $dateOfBirth, age: $age, sessionDate: $sessionDate, slot: $slot, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrialBookingCopyWith<$Res> implements $TrialBookingCopyWith<$Res> {
  factory _$TrialBookingCopyWith(_TrialBooking value, $Res Function(_TrialBooking) _then) = __$TrialBookingCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone,@JsonKey(name: 'date_of_birth', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? dateOfBirth, int? age,@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime sessionDate,@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot slot, String? note,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$TrialBookingCopyWithImpl<$Res>
    implements _$TrialBookingCopyWith<$Res> {
  __$TrialBookingCopyWithImpl(this._self, this._then);

  final _TrialBooking _self;
  final $Res Function(_TrialBooking) _then;

/// Create a copy of TrialBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? dateOfBirth = freezed,Object? age = freezed,Object? sessionDate = null,Object? slot = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_TrialBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
