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
