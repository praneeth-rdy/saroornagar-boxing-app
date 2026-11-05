// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeeStatus {

@JsonKey(name: 'trainee_id') String get traineeId;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'photo_path') String? get photoPath;/// The monthly fee on the month's first day; null without a date of birth.
@JsonKey(name: 'tier_amount') int? get tierAmount;/// The sum of the month's payments, 0 when none.
@JsonKey(name: 'paid_amount') int get paidAmount;@JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? get lastPaidOn;
/// Create a copy of FeeStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeeStatusCopyWith<FeeStatus> get copyWith => _$FeeStatusCopyWithImpl<FeeStatus>(this as FeeStatus, _$identity);

  /// Serializes this FeeStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FeeStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeeStatus&&(identical(other.traineeId, _this.traineeId) || other.traineeId == _this.traineeId)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.photoPath, _this.photoPath) || other.photoPath == _this.photoPath)&&(identical(other.tierAmount, _this.tierAmount) || other.tierAmount == _this.tierAmount)&&(identical(other.paidAmount, _this.paidAmount) || other.paidAmount == _this.paidAmount)&&(identical(other.lastPaidOn, _this.lastPaidOn) || other.lastPaidOn == _this.lastPaidOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FeeStatus;
  return Object.hash(runtimeType,_this.traineeId,_this.fullName,_this.photoPath,_this.tierAmount,_this.paidAmount,_this.lastPaidOn);
}

@override
String toString() {
  final _this = this as FeeStatus;
  return 'FeeStatus(traineeId: ${_this.traineeId}, fullName: ${_this.fullName}, photoPath: ${_this.photoPath}, tierAmount: ${_this.tierAmount}, paidAmount: ${_this.paidAmount}, lastPaidOn: ${_this.lastPaidOn})';
}


}

/// @nodoc
abstract mixin class $FeeStatusCopyWith<$Res>  {
  factory $FeeStatusCopyWith(FeeStatus value, $Res Function(FeeStatus) _then) = _$FeeStatusCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'tier_amount') int? tierAmount,@JsonKey(name: 'paid_amount') int paidAmount,@JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? lastPaidOn
});




}
/// @nodoc
class _$FeeStatusCopyWithImpl<$Res>
    implements $FeeStatusCopyWith<$Res> {
  _$FeeStatusCopyWithImpl(this._self, this._then);

  final FeeStatus _self;
  final $Res Function(FeeStatus) _then;

/// Create a copy of FeeStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? traineeId = null,Object? fullName = null,Object? photoPath = freezed,Object? tierAmount = freezed,Object? paidAmount = null,Object? lastPaidOn = freezed,}) {
  return _then(FeeStatus(
traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,tierAmount: freezed == tierAmount ? _self.tierAmount : tierAmount // ignore: cast_nullable_to_non_nullable
as int?,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,lastPaidOn: freezed == lastPaidOn ? _self.lastPaidOn : lastPaidOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeeStatus].
extension FeeStatusPatterns on FeeStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeeStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeeStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeeStatus value)  $default,){
final _that = this;
switch (_that) {
case _FeeStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeeStatus value)?  $default,){
final _that = this;
switch (_that) {
case _FeeStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'tier_amount')  int? tierAmount, @JsonKey(name: 'paid_amount')  int paidAmount, @JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? lastPaidOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeeStatus() when $default != null:
return $default(_that.traineeId,_that.fullName,_that.photoPath,_that.tierAmount,_that.paidAmount,_that.lastPaidOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'tier_amount')  int? tierAmount, @JsonKey(name: 'paid_amount')  int paidAmount, @JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? lastPaidOn)  $default,) {final _that = this;
switch (_that) {
case _FeeStatus():
return $default(_that.traineeId,_that.fullName,_that.photoPath,_that.tierAmount,_that.paidAmount,_that.lastPaidOn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'trainee_id')  String traineeId, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'tier_amount')  int? tierAmount, @JsonKey(name: 'paid_amount')  int paidAmount, @JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire)  DateTime? lastPaidOn)?  $default,) {final _that = this;
switch (_that) {
case _FeeStatus() when $default != null:
return $default(_that.traineeId,_that.fullName,_that.photoPath,_that.tierAmount,_that.paidAmount,_that.lastPaidOn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeeStatus extends FeeStatus {
  const _FeeStatus({@JsonKey(name: 'trainee_id') required this.traineeId, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'photo_path') this.photoPath, @JsonKey(name: 'tier_amount') this.tierAmount, @JsonKey(name: 'paid_amount') required this.paidAmount, @JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) this.lastPaidOn}): super._();
  factory _FeeStatus.fromJson(Map<String, dynamic> json) => _$FeeStatusFromJson(json);

@override@JsonKey(name: 'trainee_id') final  String traineeId;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'photo_path') final  String? photoPath;
/// The monthly fee on the month's first day; null without a date of birth.
@override@JsonKey(name: 'tier_amount') final  int? tierAmount;
/// The sum of the month's payments, 0 when none.
@override@JsonKey(name: 'paid_amount') final  int paidAmount;
@override@JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) final  DateTime? lastPaidOn;

/// Create a copy of FeeStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeeStatusCopyWith<_FeeStatus> get copyWith => __$FeeStatusCopyWithImpl<_FeeStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeeStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeeStatus&&(identical(other.traineeId, traineeId) || other.traineeId == traineeId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.tierAmount, tierAmount) || other.tierAmount == tierAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.lastPaidOn, lastPaidOn) || other.lastPaidOn == lastPaidOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,traineeId,fullName,photoPath,tierAmount,paidAmount,lastPaidOn);
}

@override
String toString() {
    return 'FeeStatus(traineeId: $traineeId, fullName: $fullName, photoPath: $photoPath, tierAmount: $tierAmount, paidAmount: $paidAmount, lastPaidOn: $lastPaidOn)';
}


}

/// @nodoc
abstract mixin class _$FeeStatusCopyWith<$Res> implements $FeeStatusCopyWith<$Res> {
  factory _$FeeStatusCopyWith(_FeeStatus value, $Res Function(_FeeStatus) _then) = __$FeeStatusCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'trainee_id') String traineeId,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'tier_amount') int? tierAmount,@JsonKey(name: 'paid_amount') int paidAmount,@JsonKey(name: 'last_paid_on', fromJson: _optionalDateFromWire, toJson: _optionalDateToWire) DateTime? lastPaidOn
});




}
/// @nodoc
class __$FeeStatusCopyWithImpl<$Res>
    implements _$FeeStatusCopyWith<$Res> {
  __$FeeStatusCopyWithImpl(this._self, this._then);

  final _FeeStatus _self;
  final $Res Function(_FeeStatus) _then;

/// Create a copy of FeeStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? traineeId = null,Object? fullName = null,Object? photoPath = freezed,Object? tierAmount = freezed,Object? paidAmount = null,Object? lastPaidOn = freezed,}) {
  return _then(_FeeStatus(
traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,tierAmount: freezed == tierAmount ? _self.tierAmount : tierAmount // ignore: cast_nullable_to_non_nullable
as int?,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as int,lastPaidOn: freezed == lastPaidOn ? _self.lastPaidOn : lastPaidOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
