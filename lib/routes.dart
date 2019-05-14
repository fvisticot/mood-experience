import 'package:flutter/material.dart';
import 'experiences_bloc_view.dart';
import 'login_view.dart';
import 'subscription_view.dart';
import 'password_lost_view.dart';
import 'connect_signup_view.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

final routes = {
  '/connect_signup': (BuildContext context) => new ConnectSignupView(),
  '/login': (BuildContext context) => new LoginView(),
  '/signup': (BuildContext context) => new SubscriptionView(),
  '/experiences': (BuildContext context) => new ExperiencesBlocView(),
  '/password_lost': (BuildContext context) => new PasswordLostView(),
  '/': (BuildContext context) => new ConnectSignupView(),
  /*'/cgus': (BuildContext context) {
    return new WebviewScaffold(
        url: "https://www.google.com",
        appBar: new AppBar(backgroundColor: Colors.grey, title: new Text("CGUs")));
  },*/
};
