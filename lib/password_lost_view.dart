import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_app/password_lost_viewmodel.dart';
import 'dart:ui';

class PasswordLostView extends StatefulWidget {
  @override
  createState() => new PasswordLostScreenState();
}

class PasswordLostScreenState extends State<PasswordLostView> {
  BuildContext _ctx;

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _emailTextEditingController = TextEditingController();
  PasswordLostViewModel _passwordLostViewModel = PasswordLostViewModel();
  FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    _emailTextEditingController.addListener(() =>
        _passwordLostViewModel.emailText.add(_emailTextEditingController.text));
  }

  @override
  dispose() {
    _emailTextEditingController.dispose();
    super.dispose();
  }

  PasswordLostScreenState() {}

  void _doResetPassword() async {
    try {
      _emailFocusNode.unfocus();
      await _passwordLostViewModel
          .doResetPassword(_emailTextEditingController.text);
      _emailTextEditingController.clear();
      Navigator.of(context).pushNamed("/login");
    } catch (err) {
      print(err.toString());
      //_showSnackBar(err.toString());
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    var resetPasswodButton = StreamBuilder<bool>(
      stream: _passwordLostViewModel.isButtonEnabled,
      builder: (context, snapshot) {
        return RaisedButton(
          onPressed: !_isDisplayButton(snapshot.data) ? null : _doResetPassword,
          child: new Text(
            "REINITIALISER LE MOT DE PASSE",
            style: new TextStyle(color: Colors.white),
          ),
          color: new Color.fromRGBO(0, 126, 236, 1.0),
        );
      },
    );

    var passwordLostForm = new Column(
      children: <Widget>[
        new Text(
          "Mot de passe perdu ?",
          textScaleFactor: 2.0,
          style: new TextStyle(color: Colors.white),
        ),
        new Form(
          key: formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                child: StreamBuilder<String>(
                    stream: _passwordLostViewModel.emailErrorText,
                    builder: (context, snapshot) {
                      return TextFormField(
                        autofocus: true,
                        focusNode: _emailFocusNode,
                        controller: _emailTextEditingController,
                        decoration: new InputDecoration(
                            labelText: "Email",
                            labelStyle: Theme.of(context).textTheme.body1,
                            border: OutlineInputBorder(),
                            hintText: "Email",
                            errorText: snapshot.data ?? null),
                        keyboardType: TextInputType.emailAddress,
                      );
                    }),
              ),
            ],
          ),
        ),
        _isLoading ? new CircularProgressIndicator() : resetPasswodButton
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return new Card(
      child: new Stack(children: <Widget>[
        new Container(
            decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("images/splashscreen.png"),
              fit: BoxFit.cover),
        )),
        new AppBar(
          backgroundColor: new Color.fromRGBO(255, 0, 0, 0.0),
          elevation: 0.0,
        ),
        new Center(
            child: new Container(
          child: passwordLostForm,
          height: 350.0,
          width: 300.0,
        ))
      ]),
    );
  }

  bool _isDisplayButton(val) {
    if (val == null) return false;
    if (val && val == true) {
      return true;
    }
    return false;
  }
}
