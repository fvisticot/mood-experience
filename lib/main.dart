import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes.dart';
import 'mood_strings.dart';


class MoodLocalizationsDelegate extends LocalizationsDelegate<MoodStrings> {
  const MoodLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {print('IsSupported: ${locale}'); return ['en', 'fr'].contains(locale.languageCode);}

  @override
  Future<MoodStrings> load(Locale locale) { return  MoodStrings.load(locale);}

  @override
  bool shouldReload(MoodLocalizationsDelegate old) => false;
}


class MoodApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    //_scheduleNotification();

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      routes: routes,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        new MoodLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('fr', 'FR'),
      ],
    );
  }


}

void main() => runApp(new MoodApp());
