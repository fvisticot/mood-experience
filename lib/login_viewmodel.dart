import 'firebase_auth.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'email_validator.dart';
import 'password_validator.dart';

class LoginViewModel {

  FirebaseAuthentication api = new FirebaseAuthentication();

  var _emailTextController = StreamController<String>.broadcast();
  var _passwordTextController = StreamController<String>.broadcast();
  var _observable;

  LoginViewModel() {
    _observable= Observable.combineLatest2(
        _emailTextController.stream,
        _passwordTextController.stream,
            (email, password)  => isValidForm(email, password));
  }


  @override
  Sink get emailText {
    return _emailTextController;
  }

  @override
  Sink get passwordText {
    return _passwordTextController;
  }

  @override
  void dispose() {
    _passwordTextController.close();
    _emailTextController.close();
  }

  @override
  Stream<String> get emailErrorText {
    return _emailTextController.stream.map((email) {
      return EmailValidator.isEmailValid(email) ? null : "email not valid";
    });
  }

  @override
  Stream<String> get passwordErrorText {
    return _passwordTextController.stream.map((password) {
      return PasswordValidator.isPasswordValid(password)
          ? null
          : "password not valid";
    });
  }

  @override
  Stream<bool> get isButtonEnabled {
    return _observable;
  }

  bool isValidForm(email, password) {
    return PasswordValidator.isPasswordValid(password) && EmailValidator.isEmailValid(email);
  }


  doFacebookLogin() async {
    api.facebookLogin().then((userId) {
    }).catchError((Exception error) {
    });
  }

  Future<String>doGoogleLogin() async {
    try {
      return await api.googleLogin();
    } catch(err) {
      throw err;
    }
  }

  Future<String>doLogin(String email, String password) async {
    try {
      return await api.login(email, password);
    } catch(err) {
      throw err;
    }
  }


}