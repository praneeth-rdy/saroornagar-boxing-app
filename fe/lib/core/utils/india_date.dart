import 'package:intl/intl.dart';

// India has no daylight saving, so a fixed offset is exact.
const _indiaOffset = Duration(hours: 5, minutes: 30);

/// The current India wall-clock time, carried in a UTC [DateTime] so its fields read as IST.
DateTime indiaNow() => DateTime.now().toUtc().add(_indiaOffset);

/// [instant] as India wall-clock time, carried like [indiaNow].
DateTime toIndiaTime(DateTime instant) => instant.toUtc().add(_indiaOffset);

/// The calendar date of [moment] as a local midnight, the form date pickers use.
DateTime dateOnly(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// A date as Postgres `date` text: `YYYY-MM-DD`.
String wireDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// Parses Postgres `date` text into a local midnight.
DateTime parseWireDate(String value) => dateOnly(DateTime.parse(value));

/// `6:02 am` style time; lower-case am and pm.
String formatClockTime(DateTime time) =>
    DateFormat('h:mm a').format(time).toLowerCase();
