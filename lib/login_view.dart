import 'dart:ui';

import 'package:flutter/material.dart';

import 'auth.dart';
import 'login_viewmodel.dart';
import 'mood_strings.dart';
import 'user_utils.dart';
import 'ensure_visible.dart';

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
          style: new TextStyle(color: _pressed ? Colors.red : Colors.white),
        ),
        onTap: () => widget.onTap(),
        onHighlightChanged: (state) => setState(() {
              _pressed = state;
            }));
  }
}

class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginView> implements AuthStateListener {

  LoginViewModel _loginViewModel = LoginViewModel();
  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _pwdTextEditingController = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _pwdFocusNode = FocusNode();

  @override
  void initState() {
    _emailTextEditingController.addListener(
        () => _loginViewModel.emailText.add(_emailTextEditingController.text));
    _pwdTextEditingController.addListener(
        () => _loginViewModel.passwordText.add(_pwdTextEditingController.text));
  }

  @override
  dispose() {
    _emailTextEditingController.dispose();
    _pwdTextEditingController.dispose();
    super.dispose();
  }

  LoginScreenState() {
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
  }

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      //_presenter.doLogin(_email, _password);
    }
  }

  _showSnackBar(BuildContext context, String message) {
    /*Scaffold.of(context).showSnackBar(SnackBar(
      content: new Text(message),
      action: new SnackBarAction(
        label: "dismiss",
        onPressed: () {
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    ));
    *///TODO snackbar maangement when no scaffold
  }

  @override
  onAuthStateChanged(AuthState state) {
    if (state == AuthState.LOGGED_IN)
      Navigator.of(context).pushReplacementNamed("/experiences");
  }

  @override
  Widget build(BuildContext context) {
    var loginForm = new SafeArea(
        top: false,
        bottom: false,
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              AppBar(
                backgroundColor: new Color.fromRGBO(255, 0, 0, 0.0),
                elevation: 0.0,
              ),
              Text(
                "Content de vous revoir !",
                style: new TextStyle(fontSize: 19.0, color: Colors.white),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0),
                  child: RaisedButton(
                    onPressed: () {
                      //Navigator.of(_ctx).pushNamed("/register");
                      _doFacebookLogin();
                    },
                    child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: <Widget>[
                          Image(
                              image: new AssetImage('images/fb-icon.png'),
                              width: 30.0,
                              height: 40.0),
                          Center(
                              child: new Text('FACEBOOK',
                                  style: new TextStyle(color: Colors.white)))
                        ]),
                    color: new Color.fromRGBO(59, 89, 152, 1.0),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
                  child: RaisedButton(
                    onPressed: () {
                      _doGoogleLogin();
                    },
                    child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: <Widget>[
                          Image(
                              image: new AssetImage('images/google-icon.png'),
                              width: 30.0,
                              height: 30.0),
                          Center(
                              child: new Text('GOOGLE',
                                  style: new TextStyle(color: Colors.black)))
                        ]),
                    color: new Color.fromRGBO(255, 255, 255, 1.0),
                  )),
              Padding(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        color: Colors.white,
                        height: 3.0,
                      )),
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: new Text('Or',
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: 18.0, color: Colors.white))),
                      Expanded(
                          child: Container(
                        color: Colors.white,
                        height: 3.0,
                      )),
                    ],
                  )),
              new Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
                  child: new Form(
                    key: formKey,
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<String>(
                              stream: _loginViewModel.emailErrorText,
                              builder: (context, snapshot) {
                                return TextFormField(
                                  controller: _emailTextEditingController,
                                  focusNode: _emailFocusNode,
                                  decoration: new InputDecoration(
                                      labelText: "Email",
                                      labelStyle:
                                          Theme.of(context).textTheme.body1,
                                      border: OutlineInputBorder(),
                                      hintText: "Email",
                                      errorText: snapshot.data ?? null),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                );
                              }),
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<String>(
                            stream: _loginViewModel.passwordErrorText,
                            builder: (context, snapshot) {
                              return TextFormField(
                                controller: _pwdTextEditingController,
                                focusNode: _pwdFocusNode,
                                decoration: new InputDecoration(
                                    labelStyle:
                                        Theme.of(context).textTheme.body1,
                                    border: OutlineInputBorder(),
                                    errorText: snapshot.data ?? null,
                                    hintText:
                                        MoodStrings.of(context).password(),
                                    labelText:
                                        MoodStrings.of(context).password()),
                                obscureText: true,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
              new Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
                  child: StreamBuilder<bool>(
                      stream: _loginViewModel.isButtonEnabled,
                      builder: (context, snapshot) {
                        return RaisedButton(
                          onPressed: !_isDisplayButton(snapshot.data)?null: () {
                            //Navigator.of(_ctx).pushNamed("/register");
                            _doLogin(_emailTextEditingController.text,
                                _pwdTextEditingController.text);
                            _submit();
                          },
                          child: new Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: <Widget>[
                                new Center(
                                    child: new Text('CONNEXION',
                                        style:
                                            new TextStyle(color: Colors.white)))
                              ]),
                          color: new Color.fromRGBO(0, 126, 236, 1.0),
                        );
                      })),
              new Padding(
                padding:
                    const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
                child: new TextLink(
                    text: 'Mot de passe perdu ?',
                    onTap: () =>
                        Navigator.of(context).pushNamed("/password_lost")),
              ),
            ],
          ),
        ));

    return new Scaffold(
        body: new Stack(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/splashscreen.png"),
                    colorFilter:
                        ColorFilter.mode(Colors.black12, BlendMode.darken),
                    fit: BoxFit.cover))),
        loginForm
      ],
    ));
  }

  _facebookLogin() {}



  @override
  void onResetPasswordSuccess() async {
    _showSnackBar(context, 'Email send');
    setState(() => _isLoading = false);
  }

  _doGoogleLogin() async {
    try {
      var userId=await _loginViewModel.doGoogleLogin();
      UserUtils().set('userId', userId);
      new UserUtils().setLogged(true.toString());
      Navigator.of(context).pushReplacementNamed("/experiences");
    } catch (err) {
      print(err);
      _showSnackBar(context, "err");
    }

  }

  _doFacebookLogin() async {
    await _loginViewModel.doFacebookLogin();
  }

  _doLogin(email, password) async {
    var userId=await _loginViewModel.doLogin(email, password);
    print('UserID=${userId}');
    UserUtils().set('userId', userId);
    new UserUtils().setLogged(true.toString());
    Navigator.of(context).pushReplacementNamed("/experiences");
  }

  bool _isDisplayButton(val) {
    if (val == null) return false;
    if (val && val == true) {
      return true;
    }
    return false;
  }
}
