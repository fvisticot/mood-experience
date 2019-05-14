import 'dart:ui';

import 'package:flutter/material.dart';
import 'model/user.dart';
import 'auth.dart';
import 'user_utils.dart';
import 'subscription_viewmodel.dart';
import 'mood_strings.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'dart:async';

class TextLink extends StatefulWidget {
  String text;
  GestureTapCallback onTap;

  TextLink({this.text, this.onTap});

  @override
  State<StatefulWidget> createState() {
    return new TextLinkState(text);
  }
}

class TextLinkState extends State<TextLink> {
  BuildContext _ctx;
  bool _pressed;
  String _text;

  TextLinkState(this._text) {
    _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return new InkWell(
        child: new Text(
          _text,
          textAlign: TextAlign.center,
          style: new TextStyle(color: _pressed ? Colors.red : Colors.white),
        ),
        onTap: () => widget.onTap(),
        onHighlightChanged: (state) => setState(() {
              _pressed = state;
            }));
  }
}

class SubscriptionView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SubscriptionViewState();
  }
}

class SubscriptionViewState extends State<SubscriptionView>
    implements AuthStateListener {
  BuildContext _ctx;

  ScrollController _scrollController;
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _pwdTextEditingController = TextEditingController();
  TextEditingController _pseudoTextEditingController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _pwdFocusNode = FocusNode();
  FocusNode _pseudoFocusNode = FocusNode();

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _password, _email, _pseudo;
  SubscriptionViewModel _subscriptionViewModel = SubscriptionViewModel();

  //final _flutterWebviewPlugin = new FlutterWebviewPlugin();

  void onChange() {
    _scrollController.animateTo(250.0,
        duration: new Duration(milliseconds: 450), curve: Curves.decelerate);
  }

  @override
  void initState() {
    _emailTextEditingController.addListener(() =>
        _subscriptionViewModel.emailText.add(_emailTextEditingController.text));
    _pwdTextEditingController.addListener(() => _subscriptionViewModel
        .passwordText
        .add(_pwdTextEditingController.text));
    _pseudoTextEditingController.addListener(() => _subscriptionViewModel
        .pseudoText
        .add(_pseudoTextEditingController.text));
  }

  SubscriptionViewState() {
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
    _scrollController = new ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
  }



  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  onAuthStateChanged(AuthState state) {
    if (state == AuthState.LOGGED_IN)
      Navigator.of(_ctx).pushReplacementNamed("/experiences");
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    //ButtonThemeData buttonThemeData = new ButtonThemeData(minWidth: 350.0);

    var loginForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Text(
          "Bonjour ! Inscrivez-vous :",
          style: new TextStyle(fontSize: 19.0, color: Colors.white),
        ),
        new Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0),
            child: new RaisedButton(
              onPressed: () {
                //onChange();
                _doFacebookRegister();
              },
              child: new Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: <Widget>[
                    new Image(
                        image: new AssetImage('images/fb-icon.png'),
                        width: 30.0,
                        height: 40.0),
                    new Center(
                        child: new Text('FACEBOOK',
                            style: new TextStyle(color: Colors.white)))
                  ]),
              color: new Color.fromRGBO(59, 89, 152, 1.0),
            )),
        new Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
            child: new RaisedButton(
              onPressed: () {
                //Navigator.of(_ctx).pushNamed("/register");
                _doGoogleRegister();
              },
              child: new Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: <Widget>[
                    new Image(
                        image: new AssetImage('images/google-icon.png'),
                        width: 30.0,
                        height: 30.0),
                    new Center(
                        child: new Text('GOOGLE',
                            style: new TextStyle(color: Colors.black)))
                  ]),
              color: new Color.fromRGBO(255, 255, 255, 1.0),
            )),
        new Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Expanded(
                    child: Container(
                  color: Colors.white,
                  height: 3.0,
                )),
                new Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Text('Or',
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: 18.0, color: Colors.white))),
                new Expanded(
                    child: Container(
                  color: Colors.white,
                  height: 3.0,
                )),
              ],
            )),
        new Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0),
            child: new Form(
              key: formKey,
              child: new Column(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<String>(
                        stream: _subscriptionViewModel.emailErrorText,
                        builder: (context, snapshot) {
                          return TextFormField(
                            focusNode: _emailFocusNode,
                            controller: _emailTextEditingController,
                            onSaved: (val) => _email = val,
                            decoration: new InputDecoration(
                              labelText: "Email",
                              labelStyle: Theme.of(context).textTheme.body1,
                              border: OutlineInputBorder(),
                              hintText: "Email",
                              errorText: snapshot.data ?? null,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                          );
                        }),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<String>(
                        stream: _subscriptionViewModel.passwordErrorText,
                        builder: (context, snapshot) {
                          return TextFormField(
                            focusNode: _pwdFocusNode,
                            controller: _pwdTextEditingController,
                            onSaved: (val) => _password = val,
                            decoration: new InputDecoration(
                              labelText: MoodStrings.of(context).password(),
                              labelStyle: Theme.of(context).textTheme.body1,
                              border: OutlineInputBorder(),
                              errorText: snapshot.data ?? null,
                              hintText: "Password",
                            ),
                            obscureText: true,
                          );
                        }),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<String>(
                        stream: _subscriptionViewModel.pseudoErrorText,
                        builder: (context, snapshot) {
                          return TextFormField(
                            focusNode: _pseudoFocusNode,
                            controller: _pseudoTextEditingController,
                            onSaved: (val) => _pseudo = val,
                            decoration: new InputDecoration(
                              labelText: 'pseudo',
                              labelStyle: Theme.of(context).textTheme.body1,
                              border: OutlineInputBorder(),
                              errorText: snapshot.data ?? null,
                              hintText: "Pseudo",
                            ),
                            obscureText: true,
                          );
                        }),
                  ),
                ],
              ),
            )),
        new Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
            child: StreamBuilder<bool>(
                stream: _subscriptionViewModel.isButtonEnabled,
                builder: (context, snapshot) {
                  return RaisedButton(
                    onPressed: !_isDisplayButton(snapshot.data)?null: () {
                      //Navigator.of(_ctx).pushNamed("/register");
                      _doRegister(_emailTextEditingController.text, _pwdTextEditingController.text, _pseudoTextEditingController.text);
                    },
                    child: new Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: <Widget>[
                          new Center(
                              child: new Text("S'INSCRIRE",
                                  style: new TextStyle(color: Colors.white)))
                        ]),
                    color: new Color.fromRGBO(0, 126, 236, 1.0),
                  );
                })),
        new Padding(
          padding: const EdgeInsets.only(
              top: 20.0, left: 40.0, right: 40.0, bottom: 320.0),
          child: new TextLink(
              text:
                  "En cliquant sur 'Inscription', vous acceptez les Conditions générales d'utilisation.",
              onTap: () => _displayCGUs()),
        ),
      ],
    );

    /*return new Scaffold(
      appBar: null,
      body: new Container(
          child: new Center(
              child: new Padding(
                  padding: EdgeInsets.only(top: 100.0), child: loginForm)),
          decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("images/splashscreen.png"),
                fit: BoxFit.cover),
          )
      ),
    );
    */

    /*
    return new Card(
        child: new Stack(
          children: <Widget>[
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
                child: new Padding(
                    padding: EdgeInsets.only(top: 100.0), child: loginForm)),
          ],
        ));
        */

    return new Card(
        child: new Stack(
      children: <Widget>[
        new Container(
            decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("images/splashscreen.png"),
              fit: BoxFit.fill),
        )),
        new AppBar(
          backgroundColor: new Color.fromRGBO(255, 0, 0, 0.0),
          elevation: 0.0,
        ),
        new Padding(
            padding: EdgeInsets.only(top: 70.0),
            child: new SingleChildScrollView(
                controller: _scrollController,
                child: new Padding(
                    padding: EdgeInsets.only(top: 30.0), child: loginForm))),
      ],
    ));

    /*
    return new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: new Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max
            ,children: [
          new Card(
              color: Colors.red,
              child: new Stack(
                children: <Widget>[
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
                      child: new Padding(
                          padding: EdgeInsets.only(top: 100.0),
                          child: loginForm)),
                ],
              ))
        ]));*/
  }

  _displayCGUs() {
    print('display CGUs');
    Navigator.of(context).pushNamed("/cgus");
  }

  bool _isDisplayButton(val) {
    if (val == null) return false;
    if (val && val == true) {
      return true;
    }
    return false;
  }

  @override
  void onRegisterError(String errorTxt) {
    _showSnackBar(errorTxt);
    setState(() => _isLoading = false);
    Navigator.of(_ctx).pushReplacementNamed("/login");
  }

  @override
  void onRegisterSuccess(String userId) async {
    print('Register success: ' + userId);
    setState(() => _isLoading = false);
    Navigator.of(_ctx).pushReplacementNamed("/experiences");
  }

  _doFacebookRegister() async {
    await _subscriptionViewModel.doFacebookRegister();
  }

  _doGoogleRegister() async {
    await _subscriptionViewModel.doGoogleRegister();
  }

  void _doRegister(email, password, pseudo) {
    _subscriptionViewModel.doRegister(email, password, pseudo);
  }


}
