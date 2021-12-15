import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final _kDBCSRegExp = RegExp(r'[^\x00-\xff]');

/// A [TextInputFormatter] that prevents the insertion of more characters
/// (currently defined as Unicode scalar values) than allowed.
///
/// Since this formatter only prevents new characters from being added to the
/// text, it preserves the existing [TextEditingValue.selection].
///
///  * [maxLength], which discusses the precise meaning of "number of
///    characters" and how it may differ from the intuitive meaning.
class DBCSLengthLimitingTextInputFormatter extends TextInputFormatter {
  /// Creates a formatter that prevents the insertion of more characters than a
  /// limit.
  ///
  /// The [maxLength] must be null, -1 or greater than zero. If it is null or -1
  /// then no limit is enforced.
  DBCSLengthLimitingTextInputFormatter(this.maxLength)
      : assert(maxLength == -1 || maxLength > 0);

  /// The limit on the number of characters (i.e. Unicode scalar values) this formatter
  /// will allow.
  ///
  /// The value must be null or greater than zero. If it is null, then no limit
  /// is enforced.
  ///
  /// This formatter does not currently count Unicode grapheme clusters (i.e.
  /// characters visible to the user), it counts Unicode scalar values, which leaves
  /// out a number of useful possible characters (like many emoji and composed
  /// characters), so this will be inaccurate in the presence of those
  /// characters. If you expect to encounter these kinds of characters, be
  /// generous in the maxLength used.
  ///
  /// For instance, the character "ö" can be represented as '\u{006F}\u{0308}',
  /// which is the letter "o" followed by a composed diaeresis "¨", or it can
  /// be represented as '\u{00F6}', which is the Unicode scalar value "LATIN
  /// SMALL LETTER O WITH DIAERESIS". In the first case, the text field will
  /// count two characters, and the second case will be counted as one
  /// character, even though the user can see no difference in the input.
  ///
  /// Similarly, some emoji are represented by multiple scalar values. The
  /// Unicode "THUMBS UP SIGN + MEDIUM SKIN TONE MODIFIER", "👍🏽", should be
  /// counted as a single character, but because it is a combination of two
  /// Unicode scalar values, '\u{1F44D}\u{1F3FD}', it is counted as two
  /// characters.
  ///
  /// ### Composing text behaviors
  ///
  /// There is no guarantee for the final value before the composing ends.
  /// So while the value is composing, the constraint of [maxLength] will be
  /// temporary lifted until the composing ends.
  ///
  /// In addition, if the current value already reached the [maxLength],
  /// composing is not allowed.
  final int maxLength;

  /// Truncate the given TextEditingValue to maxLength characters.
  ///
  /// See also:
  ///  * [Dart's characters package](https://pub.dev/packages/characters).
  ///  * [Dart's documenetation on runes and grapheme clusters](https://dart.dev/guides/language/language-tour#runes-and-grapheme-clusters).
  @visibleForTesting
  static TextEditingValue truncate(TextEditingValue value, int maxLength) {
    final iterator = CharacterRange(value.text);

    if (getCharactersWidth(value.text.characters) > maxLength) {
      while (getCharactersWidth(iterator.currentCharacters) < maxLength) {
        iterator.expandNext();
      }
    }

    final truncated = iterator.current;

    return TextEditingValue(
      text: truncated,
      selection: value.selection.copyWith(
        baseOffset: math.min(value.selection.start, truncated.length),
        extentOffset: math.min(value.selection.end, truncated.length),
      ),
      composing: TextRange.empty,
    );
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Return the new value when the old value has not reached the max
    // limit or the old value is composing too.
    if (newValue.composing.isValid) {
      if (maxLength > 0 &&
          getCharactersWidth(oldValue.text.characters) == maxLength &&
          !oldValue.composing.isValid) {
        return oldValue;
      }
      return newValue;
    }
    if (maxLength > 0 &&
        getCharactersWidth(newValue.text.characters) > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (getCharactersWidth(oldValue.text.characters) == maxLength) {
        return oldValue;
      }
      return truncate(newValue, maxLength);
    }
    return newValue;
  }
}

int getCharactersWidth(Characters chars) {
  var width = 0;

  for (final char in chars) {
    if (_kDBCSRegExp.hasMatch(char)) {
      width += 2;
    } else {
      width += 1;
    }
  }

  return width;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
