import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserUtils {
  static final UserUtils _singleton = new UserUtils._internal();
  static final storage = new FlutterSecureStorage();

  factory UserUtils() {
    return _singleton;
  }

  UserUtils._internal() {

  }

  set(key, value) async{
    print('Adding key: ${key} value: ${value}');
    await storage.write(key: key, value: value);
  }

  get(key) async {
    return await storage.read(key: key);
  }

  isLogged() async {
    try {
      var isLogged = await storage.read(key: 'logged');
      print('isLogged: ${isLogged}');
      return isLogged;
    } catch (e) {
      print(e);
    }
  }

  setLogged(value) async {
    try {
      print('Setting logged value to ${value}');
      await set('logged', value);
    } catch (e) {
      print(e);
    }
  }


}