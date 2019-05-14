import 'package:flutter_app/firestore_ds.dart';
import 'package:flutter_app/firebase_auth.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'email_validator.dart';
import 'password_validator.dart';
import 'pseudo_validator.dart';

class SubscriptionViewModel {
  FirebaseAuthentication authApi = new FirebaseAuthentication();
  FirestoreDatasource firestoreApi = new FirestoreDatasource();

  var _emailTextController = StreamController<String>.broadcast();
  var _passwordTextController = StreamController<String>.broadcast();
  var _pseudoTextController = StreamController<String>.broadcast();
  var _observable;

  SubscriptionViewModel() {
    _observable= Observable.combineLatest3(
        _emailTextController.stream,
        _passwordTextController.stream,
            _pseudoTextController.stream,
            (email, password, pseudo)  => isValidForm(email, password, pseudo));
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
  Sink get pseudoText {
    return _pseudoTextController;
  }

  @override
  void dispose() {
    _passwordTextController.close();
    _emailTextController.close();
    _pseudoTextController.close();
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
  Stream<String> get pseudoErrorText {
    return _pseudoTextController.stream.map((pseudo) {
      return PseudoValidator.isPseudoValid(pseudo) ? null : "pseudo not valid";
    });
  }

  @override
  Stream<bool> get isButtonEnabled {
    return _observable;
  }

  bool isValidForm(email, password, pseudo) {
    return PasswordValidator.isPasswordValid(password) && EmailValidator.isEmailValid(email) && PseudoValidator.isPseudoValid(pseudo);
  }

  doFacebookRegister() async {
    String userId = await authApi.facebookLogin();

  }

  doGoogleRegister() async{
    String userId = await authApi.googleLogin();
    firestoreApi.createPrivateExperience(userId: userId, name: 'me');

  }

  doRegister(String email, String password, String pseudo) async{
    print('===>register ${email}');
    var userId = await authApi.register(email, password, pseudo);
    firestoreApi.createPrivateExperience(userId: userId, name: 'me');

  }
}