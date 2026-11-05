// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClubSession {

 String get id;@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime get sessionDate;@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot get slot;@JsonKey(name: 'starts_at') String get startsAt;@JsonKey(name: 'ends_at') String get endsAt;@JsonKey(name: 'created_by') String? get createdBy;
/// Create a copy of ClubSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubSessionCopyWith<ClubSession> get copyWith => _$ClubSessionCopyWithImpl<ClubSession>(this as ClubSession, _$identity);

  /// Serializes this ClubSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClubSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionDate, _this.sessionDate) || other.sessionDate == _this.sessionDate)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.endsAt, _this.endsAt) || other.endsAt == _this.endsAt)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClubSession;
  return Object.hash(runtimeType,_this.id,_this.sessionDate,_this.slot,_this.startsAt,_this.endsAt,_this.createdBy);
}

@override
String toString() {
  final _this = this as ClubSession;
  return 'ClubSession(id: ${_this.id}, sessionDate: ${_this.sessionDate}, slot: ${_this.slot}, startsAt: ${_this.startsAt}, endsAt: ${_this.endsAt}, createdBy: ${_this.createdBy})';
}


}

/// @nodoc
abstract mixin class $ClubSessionCopyWith<$Res>  {
  factory $ClubSessionCopyWith(ClubSession value, $Res Function(ClubSession) _then) = _$ClubSessionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime sessionDate,@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot slot,@JsonKey(name: 'starts_at') String startsAt,@JsonKey(name: 'ends_at') String endsAt,@JsonKey(name: 'created_by') String? createdBy
});




}
/// @nodoc
class _$ClubSessionCopyWithImpl<$Res>
    implements $ClubSessionCopyWith<$Res> {
  _$ClubSessionCopyWithImpl(this._self, this._then);

  final ClubSession _self;
  final $Res Function(ClubSession) _then;

/// Create a copy of ClubSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionDate = null,Object? slot = null,Object? startsAt = null,Object? endsAt = null,Object? createdBy = freezed,}) {
  return _then(ClubSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubSession].
extension ClubSessionPatterns on ClubSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubSession value)  $default,){
final _that = this;
switch (_that) {
case _ClubSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubSession value)?  $default,){
final _that = this;
switch (_that) {
case _ClubSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot, @JsonKey(name: 'starts_at')  String startsAt, @JsonKey(name: 'ends_at')  String endsAt, @JsonKey(name: 'created_by')  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubSession() when $default != null:
return $default(_that.id,_that.sessionDate,_that.slot,_that.startsAt,_that.endsAt,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot, @JsonKey(name: 'starts_at')  String startsAt, @JsonKey(name: 'ends_at')  String endsAt, @JsonKey(name: 'created_by')  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _ClubSession():
return $default(_that.id,_that.sessionDate,_that.slot,_that.startsAt,_that.endsAt,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate)  DateTime sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire)  SessionSlot slot, @JsonKey(name: 'starts_at')  String startsAt, @JsonKey(name: 'ends_at')  String endsAt, @JsonKey(name: 'created_by')  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _ClubSession() when $default != null:
return $default(_that.id,_that.sessionDate,_that.slot,_that.startsAt,_that.endsAt,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubSession extends ClubSession {
  const _ClubSession({required this.id, @JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) required this.sessionDate, @JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) required this.slot, @JsonKey(name: 'starts_at') required this.startsAt, @JsonKey(name: 'ends_at') required this.endsAt, @JsonKey(name: 'created_by') this.createdBy}): super._();
  factory _ClubSession.fromJson(Map<String, dynamic> json) => _$ClubSessionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) final  DateTime sessionDate;
@override@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) final  SessionSlot slot;
@override@JsonKey(name: 'starts_at') final  String startsAt;
@override@JsonKey(name: 'ends_at') final  String endsAt;
@override@JsonKey(name: 'created_by') final  String? createdBy;

/// Create a copy of ClubSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubSessionCopyWith<_ClubSession> get copyWith => __$ClubSessionCopyWithImpl<_ClubSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubSession&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionDate, sessionDate) || other.sessionDate == sessionDate)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionDate,slot,startsAt,endsAt,createdBy);
}

@override
String toString() {
    return 'ClubSession(id: $id, sessionDate: $sessionDate, slot: $slot, startsAt: $startsAt, endsAt: $endsAt, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$ClubSessionCopyWith<$Res> implements $ClubSessionCopyWith<$Res> {
  factory _$ClubSessionCopyWith(_ClubSession value, $Res Function(_ClubSession) _then) = __$ClubSessionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'session_date', fromJson: parseWireDate, toJson: wireDate) DateTime sessionDate,@JsonKey(fromJson: SessionSlot.fromWire, toJson: _slotToWire) SessionSlot slot,@JsonKey(name: 'starts_at') String startsAt,@JsonKey(name: 'ends_at') String endsAt,@JsonKey(name: 'created_by') String? createdBy
});




}
/// @nodoc
class __$ClubSessionCopyWithImpl<$Res>
    implements _$ClubSessionCopyWith<$Res> {
  __$ClubSessionCopyWithImpl(this._self, this._then);

  final _ClubSession _self;
  final $Res Function(_ClubSession) _then;

/// Create a copy of ClubSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionDate = null,Object? slot = null,Object? startsAt = null,Object? endsAt = null,Object? createdBy = freezed,}) {
  return _then(_ClubSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionDate: null == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as SessionSlot,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
