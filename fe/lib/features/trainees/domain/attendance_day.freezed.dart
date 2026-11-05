// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AttendanceDay {

 DateTime get date;/// Present batches in day order: morning, evening, then extras.
 List<SessionSlot> get slots;/// `HH:mm:ss` starts of the present extras that carry one, earliest first.
 List<String> get extraStarts;
/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceDayCopyWith<AttendanceDay> get copyWith => _$AttendanceDayCopyWithImpl<AttendanceDay>(this as AttendanceDay, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AttendanceDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceDay&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.slots, _this.slots)&&const DeepCollectionEquality().equals(other.extraStarts, _this.extraStarts));
}


@override
int get hashCode {
  final _this = this as AttendanceDay;
  return Object.hash(runtimeType,_this.date,const DeepCollectionEquality().hash(_this.slots),const DeepCollectionEquality().hash(_this.extraStarts));
}

@override
String toString() {
  final _this = this as AttendanceDay;
  return 'AttendanceDay(date: ${_this.date}, slots: ${_this.slots}, extraStarts: ${_this.extraStarts})';
}


}

/// @nodoc
abstract mixin class $AttendanceDayCopyWith<$Res>  {
  factory $AttendanceDayCopyWith(AttendanceDay value, $Res Function(AttendanceDay) _then) = _$AttendanceDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, List<SessionSlot> slots, List<String> extraStarts
});




}
/// @nodoc
class _$AttendanceDayCopyWithImpl<$Res>
    implements $AttendanceDayCopyWith<$Res> {
  _$AttendanceDayCopyWithImpl(this._self, this._then);

  final AttendanceDay _self;
  final $Res Function(AttendanceDay) _then;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? slots = null,Object? extraStarts = null,}) {
  return _then(AttendanceDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<SessionSlot>,extraStarts: null == extraStarts ? _self.extraStarts : extraStarts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceDay].
extension AttendanceDayPatterns on AttendanceDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceDay value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceDay value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  List<SessionSlot> slots,  List<String> extraStarts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that.date,_that.slots,_that.extraStarts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  List<SessionSlot> slots,  List<String> extraStarts)  $default,) {final _that = this;
switch (_that) {
case _AttendanceDay():
return $default(_that.date,_that.slots,_that.extraStarts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  List<SessionSlot> slots,  List<String> extraStarts)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceDay() when $default != null:
return $default(_that.date,_that.slots,_that.extraStarts);case _:
  return null;

}
}

}

/// @nodoc


class _AttendanceDay extends AttendanceDay {
  const _AttendanceDay({required this.date, required  List<SessionSlot> slots,  List<String> extraStarts = const <String>[]}): _slots = slots,_extraStarts = extraStarts,super._();
  

@override final  DateTime date;
/// Present batches in day order: morning, evening, then extras.
 final  List<SessionSlot> _slots;
/// Present batches in day order: morning, evening, then extras.
@override List<SessionSlot> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}

/// `HH:mm:ss` starts of the present extras that carry one, earliest first.
 final  List<String> _extraStarts;
/// `HH:mm:ss` starts of the present extras that carry one, earliest first.
@override@JsonKey() List<String> get extraStarts {
  if (_extraStarts is EqualUnmodifiableListView) return _extraStarts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extraStarts);
}


/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceDayCopyWith<_AttendanceDay> get copyWith => __$AttendanceDayCopyWithImpl<_AttendanceDay>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceDay&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.slots, _slots)&&const DeepCollectionEquality().equals(other.extraStarts, _extraStarts));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_slots),const DeepCollectionEquality().hash(_extraStarts));
}

@override
String toString() {
    return 'AttendanceDay(date: $date, slots: $slots, extraStarts: $extraStarts)';
}


}

/// @nodoc
abstract mixin class _$AttendanceDayCopyWith<$Res> implements $AttendanceDayCopyWith<$Res> {
  factory _$AttendanceDayCopyWith(_AttendanceDay value, $Res Function(_AttendanceDay) _then) = __$AttendanceDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, List<SessionSlot> slots, List<String> extraStarts
});




}
/// @nodoc
class __$AttendanceDayCopyWithImpl<$Res>
    implements _$AttendanceDayCopyWith<$Res> {
  __$AttendanceDayCopyWithImpl(this._self, this._then);

  final _AttendanceDay _self;
  final $Res Function(_AttendanceDay) _then;

/// Create a copy of AttendanceDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? slots = null,Object? extraStarts = null,}) {
  return _then(_AttendanceDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<SessionSlot>,extraStarts: null == extraStarts ? _self._extraStarts : extraStarts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
