import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FirebaseAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FacebookLogin _facebookSignIn = FacebookLogin();

  resetPassword(String email) async {
    print('Reset pwd for email: ${email} on firebase');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return;
    } catch (e) {
      throw e;
    }
  }

  Future<String>login(String email, String password) async {
    try {
      final FirebaseUser createdUser = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('User logged: ${createdUser}');
      print('UserId: ${createdUser.uid}');
      return createdUser.uid;
    } catch (e) {
      print('Exception fired');
      throw new Exception(e);
    }
  }

  facebookLogin() async {
    try {
      final FacebookLoginResult result = await _facebookSignIn
          .logInWithReadPermissions(['email']);
      print(result);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          FirebaseUser user = await _auth.signInWithFacebook(
              accessToken: accessToken.token);
          return user.uid;
          break;
        case FacebookLoginStatus.cancelledByUser:
          print('Login cancelled by the user.');
          break;
        case FacebookLoginStatus.error:
          print('Something went wrong with the login process.\n'
              'Here\'s the error Facebook gave us: ${result.errorMessage}');
          break;
      }
    } catch (e) {
      print(e);
    }
  }

  googleLogin() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return user.uid;
  }

  setUserPhoto(String photoUrl) async {
    print('Updating photoUrl: ${photoUrl}');

    //FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

    UserUpdateInfo userInfo = new UserUpdateInfo();
    userInfo.photoUrl = photoUrl;
    userInfo.displayName = 'fred';
    _auth.updateProfile(userInfo);

    /*
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      print('After auth');
      if (firebaseAuth != null) {
        _auth.updateProfile(userInfo);
      }
    } catch(e) {
      print(e);
    }
    */


  }

  logout() async {
    print('Logout user on firebase');
    await _auth.signOut();
    print('User logout');
  }

  register(String email, String password, String pseudo) async {
    print('Registering User on firebase');
    try {
      final FirebaseUser createdUser = await _auth
          .createUserWithEmailAndPassword(
          email: email, password: password);
      print('User created: ${createdUser}');
      //user.uid = createdUser.uid;
      return createdUser.uid;;
    } catch (e) {
      print(e);
    }
  }
}