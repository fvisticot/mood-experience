import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'i18n/mood_messages_all.dart';

class MoodStrings {
  MoodStrings(Locale locale) : _localeName = locale.toString();

  final String _localeName;

  static Future<MoodStrings> load(Locale locale) {
    return initializeMessages(locale.toString())
        .then((res) {
      return new MoodStrings(locale);
    });
  }

  static MoodStrings of(BuildContext context) {
    return Localizations.of<MoodStrings>(context, MoodStrings);
  }

  String password() {
    return Intl.message(
        'password',
        name: 'password',
        args: [],
        desc: 'Password desc',
        locale: _localeName
    );
  }


  String register() {
    return Intl.message(
        'register',
        name: 'register',
        args: [],
        desc: 'Register desc',
        locale: _localeName
    );
  }

}