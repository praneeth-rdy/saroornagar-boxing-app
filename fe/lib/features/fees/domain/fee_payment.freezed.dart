// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeePayment {

 String get id;@JsonKey(name: 'trainee_id') String get traineeId; int get amount;@JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire) PaymentMethod get method;@JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate) DateTime get paidOn;/// The first day of the month the payment is for.
@JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate) DateTime get periodMonth; String? get note;@JsonKey(name: 'recorded_by') String? get recordedBy;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeePaymentCopyWith<FeePayment> get copyWith => _$FeePaymentCopyWithImpl<FeePayment>(this as FeePayment, _$identity);

  /// Serializes this FeePayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FeePayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeePayment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.traineeId, _this.traineeId) || other.traineeId == _this.traineeId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.paidOn, _this.paidOn) || other.paidOn == _this.paidOn)&&(identical(other.periodMonth, _this.periodMonth) || other.periodMonth == _this.periodMonth)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.recordedBy, _this.recordedBy) || other.recordedBy == _this.recordedBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FeePayment;
  return Object.hash(runtimeType,_this.id,_this.traineeId,_this.amount,_this.method,_this.paidOn,_this.periodMonth,_this.note,_this.recordedBy,_this.createdAt);
}

@override
String toString() {
  final _this = this as FeePayment;
  return 'FeePayment(id: ${_this.id}, traineeId: ${_this.traineeId}, amount: ${_this.amount}, method: ${_this.method}, paidOn: ${_this.paidOn}, periodMonth: ${_this.periodMonth}, note: ${_this.note}, recordedBy: ${_this.recordedBy}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $FeePaymentCopyWith<$Res>  {
  factory $FeePaymentCopyWith(FeePayment value, $Res Function(FeePayment) _then) = _$FeePaymentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'trainee_id') String traineeId, int amount,@JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire) PaymentMethod method,@JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate) DateTime paidOn,@JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate) DateTime periodMonth, String? note,@JsonKey(name: 'recorded_by') String? recordedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$FeePaymentCopyWithImpl<$Res>
    implements $FeePaymentCopyWith<$Res> {
  _$FeePaymentCopyWithImpl(this._self, this._then);

  final FeePayment _self;
  final $Res Function(FeePayment) _then;

/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? traineeId = null,Object? amount = null,Object? method = null,Object? paidOn = null,Object? periodMonth = null,Object? note = freezed,Object? recordedBy = freezed,Object? createdAt = null,}) {
  return _then(FeePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paidOn: null == paidOn ? _self.paidOn : paidOn // ignore: cast_nullable_to_non_nullable
as DateTime,periodMonth: null == periodMonth ? _self.periodMonth : periodMonth // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: freezed == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FeePayment].
extension FeePaymentPatterns on FeePayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeePayment value)  $default,){
final _that = this;
switch (_that) {
case _FeePayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeePayment value)?  $default,){
final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trainee_id')  String traineeId,  int amount, @JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire)  PaymentMethod method, @JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate)  DateTime paidOn, @JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate)  DateTime periodMonth,  String? note, @JsonKey(name: 'recorded_by')  String? recordedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
return $default(_that.id,_that.traineeId,_that.amount,_that.method,_that.paidOn,_that.periodMonth,_that.note,_that.recordedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trainee_id')  String traineeId,  int amount, @JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire)  PaymentMethod method, @JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate)  DateTime paidOn, @JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate)  DateTime periodMonth,  String? note, @JsonKey(name: 'recorded_by')  String? recordedBy, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FeePayment():
return $default(_that.id,_that.traineeId,_that.amount,_that.method,_that.paidOn,_that.periodMonth,_that.note,_that.recordedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'trainee_id')  String traineeId,  int amount, @JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire)  PaymentMethod method, @JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate)  DateTime paidOn, @JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate)  DateTime periodMonth,  String? note, @JsonKey(name: 'recorded_by')  String? recordedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FeePayment() when $default != null:
return $default(_that.id,_that.traineeId,_that.amount,_that.method,_that.paidOn,_that.periodMonth,_that.note,_that.recordedBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeePayment extends FeePayment {
  const _FeePayment({required this.id, @JsonKey(name: 'trainee_id') required this.traineeId, required this.amount, @JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire) required this.method, @JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate) required this.paidOn, @JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate) required this.periodMonth, this.note, @JsonKey(name: 'recorded_by') this.recordedBy, @JsonKey(name: 'created_at') required this.createdAt}): super._();
  factory _FeePayment.fromJson(Map<String, dynamic> json) => _$FeePaymentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'trainee_id') final  String traineeId;
@override final  int amount;
@override@JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire) final  PaymentMethod method;
@override@JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate) final  DateTime paidOn;
/// The first day of the month the payment is for.
@override@JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate) final  DateTime periodMonth;
@override final  String? note;
@override@JsonKey(name: 'recorded_by') final  String? recordedBy;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeePaymentCopyWith<_FeePayment> get copyWith => __$FeePaymentCopyWithImpl<_FeePayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeePaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.traineeId, traineeId) || other.traineeId == traineeId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.paidOn, paidOn) || other.paidOn == paidOn)&&(identical(other.periodMonth, periodMonth) || other.periodMonth == periodMonth)&&(identical(other.note, note) || other.note == note)&&(identical(other.recordedBy, recordedBy) || other.recordedBy == recordedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,traineeId,amount,method,paidOn,periodMonth,note,recordedBy,createdAt);
}

@override
String toString() {
    return 'FeePayment(id: $id, traineeId: $traineeId, amount: $amount, method: $method, paidOn: $paidOn, periodMonth: $periodMonth, note: $note, recordedBy: $recordedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FeePaymentCopyWith<$Res> implements $FeePaymentCopyWith<$Res> {
  factory _$FeePaymentCopyWith(_FeePayment value, $Res Function(_FeePayment) _then) = __$FeePaymentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'trainee_id') String traineeId, int amount,@JsonKey(fromJson: PaymentMethod.fromWire, toJson: _methodToWire) PaymentMethod method,@JsonKey(name: 'paid_on', fromJson: parseWireDate, toJson: wireDate) DateTime paidOn,@JsonKey(name: 'period_month', fromJson: parseWireDate, toJson: wireDate) DateTime periodMonth, String? note,@JsonKey(name: 'recorded_by') String? recordedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$FeePaymentCopyWithImpl<$Res>
    implements _$FeePaymentCopyWith<$Res> {
  __$FeePaymentCopyWithImpl(this._self, this._then);

  final _FeePayment _self;
  final $Res Function(_FeePayment) _then;

/// Create a copy of FeePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? traineeId = null,Object? amount = null,Object? method = null,Object? paidOn = null,Object? periodMonth = null,Object? note = freezed,Object? recordedBy = freezed,Object? createdAt = null,}) {
  return _then(_FeePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,traineeId: null == traineeId ? _self.traineeId : traineeId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,paidOn: null == paidOn ? _self.paidOn : paidOn // ignore: cast_nullable_to_non_nullable
as DateTime,periodMonth: null == periodMonth ? _self.periodMonth : periodMonth // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: freezed == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
