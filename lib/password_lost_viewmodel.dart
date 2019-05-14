import 'firebase_auth.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'email_validator.dart';

class PasswordLostViewModel {

  var _emailTextController = StreamController<String>.broadcast();
  FirebaseAuthentication _api = new FirebaseAuthentication();

  PasswordLostViewModel() {

  }

  @override
  void dispose() {
    _emailTextController.close();
  }

  @override
  Sink get emailText {
    return _emailTextController;
  }

  @override
  Stream<String> get emailErrorText {
    return _emailTextController.stream.map((email) {
      return EmailValidator.isEmailValid(email) ? null : "email not valid";
    });
  }

  doResetPassword(String email) async {
    try {
      await _api.resetPassword(email);
    } catch (err) {
     throw err;
    }
  }

  @override
  Stream<bool> get isButtonEnabled {
    return _emailTextController.stream.map((email) => isValidForm(email));;
  }

  bool isValidForm(email) {
    return EmailValidator.isEmailValid(email);
  }


}