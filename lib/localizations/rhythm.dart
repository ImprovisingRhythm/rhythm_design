import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RhythmLocalizations {
  RhythmLocalizations(this.locale);

  final Locale locale;

  static RhythmLocalizations of(BuildContext context) {
    final localization =
        Localizations.of<RhythmLocalizations>(context, RhythmLocalizations);

    if (localization == null) {
      throw FlutterError('RhythmLocalizations is not found in widget tree');
    }

    return localization;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'cut': 'Cut',
      'copy': 'Copy',
      'paste': 'Paste',
      'selectAll': 'Select all',
    },
    'zh': {
      'confirm': '确认',
      'cancel': '取消',
      'cut': '剪切',
      'copy': '复制',
      'paste': '粘贴',
      'selectAll': '全选',
    },
  };

  static List<String> languages() => _localizedValues.keys.toList();

  String _getValue(String name) {
    return _localizedValues[locale.languageCode]![name] ??
        _localizedValues['en']![name] ??
        '[Translation Error]';
  }

  String get confirm => _getValue('confirm');
  String get cancel => _getValue('cancel');
  String get cut => _getValue('cut');
  String get copy => _getValue('copy');
  String get paste => _getValue('paste');
  String get selectAll => _getValue('selectAll');

  static const List<String> _shortWeekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _shortMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String datePickerYear(int yearIndex) => yearIndex.toString();
  String datePickerMonth(int monthIndex) => _months[monthIndex - 1];
  String datePickerDayOfMonth(int dayIndex) => dayIndex.toString();
  String datePickerHour(int hour) => hour.toString();
  String datePickerHourSemanticsLabel(int hour) => "$hour o'clock";
  String datePickerMinute(int minute) => minute.toString().padLeft(2, '0');

  String datePickerMinuteSemanticsLabel(int minute) {
    if (minute == 1) return '1 minute';
    return '$minute minutes';
  }

  String datePickerMediumDate(DateTime date) {
    return '${_shortWeekdays[date.weekday - DateTime.monday]} '
        '${_shortMonths[date.month - DateTime.january]} '
        '${date.day.toString().padRight(2)}';
  }

  DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.mdy;
  DatePickerDateTimeOrder get datePickerDateTimeOrder =>
      DatePickerDateTimeOrder.dateTimeDayPeriod;

  String get anteMeridiemAbbreviation => 'AM';
  String get postMeridiemAbbreviation => 'PM';
  String get todayLabel => 'Today';

  String timerPickerHour(int hour) => hour.toString();
  String timerPickerMinute(int minute) => minute.toString();
  String timerPickerSecond(int second) => second.toString();
  String timerPickerHourLabel(int hour) => hour == 1 ? 'hour' : 'hours';

  List<String> get timerPickerHourLabels => const <String>['hour', 'hours'];
  String timerPickerMinuteLabel(int minute) => 'min.';
  List<String> get timerPickerMinuteLabels => const <String>['min.'];
  String timerPickerSecondLabel(int second) => 'sec.';
  List<String> get timerPickerSecondLabels => const <String>['sec.'];
}

class RhythmLocalizationsDelegate
    extends LocalizationsDelegate<RhythmLocalizations> {
  const RhythmLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      RhythmLocalizations.languages().contains(locale.languageCode);

  @override
  Future<RhythmLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<RhythmLocalizations>(
      RhythmLocalizations(locale),
    );
  }

  @override
  bool shouldReload(RhythmLocalizationsDelegate old) => false;
}

/// Determines the order of the columns inside [DatePicker] in
/// time and date time mode.
enum DatePickerDateTimeOrder {
  /// Order of the columns, from left to right: date, hour, minute, am/pm.
  ///
  /// Example: Fri Aug 31 | 02 | 08 | PM.
  dateTimeDayPeriod,

  /// Order of the columns, from left to right: date, am/pm, hour, minute.
  ///
  /// Example: Fri Aug 31 | PM | 02 | 08.
  dateDayPeriodTime,

  /// Order of the columns, from left to right: hour, minute, am/pm, date.
  ///
  /// Example: 02 | 08 | PM | Fri Aug 31.
  timeDayPeriodDate,

  /// Order of the columns, from left to right: am/pm, hour, minute, date.
  ///
  /// Example: PM | 02 | 08 | Fri Aug 31.
  dayPeriodTimeDate,
}

/// Determines the order of the columns inside [DatePicker] in date mode.
enum DatePickerDateOrder {
  /// Order of the columns, from left to right: day, month, year.
  ///
  /// Example: 12 | March | 1996.
  dmy,

  /// Order of the columns, from left to right: month, day, year.
  ///
  /// Example: March | 12 | 1996.
  mdy,

  /// Order of the columns, from left to right: year, month, day.
  ///
  /// Example: 1996 | March | 12.
  ymd,

  /// Order of the columns, from left to right: year, day, month.
  ///
  /// Example: 1996 | 12 | March.
  ydm,
}
