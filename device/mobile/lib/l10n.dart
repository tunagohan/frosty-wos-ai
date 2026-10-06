import 'package:flutter/widgets.dart';

// ponytail: inline en/ja pairs instead of ARB + gen-l10n; move to ARB if a third language is added.
extension Tr on BuildContext {
  bool get isJa => Localizations.localeOf(this).languageCode == 'ja';
  String tr(String en, String ja) => isJa ? ja : en;
}
