import 'package:flutter/material.dart';
import './subscription_view.dart';
import './login_view.dart';

class ConnectSignupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget connectSignup = new Container(
      padding: new EdgeInsets.all(8.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new RaisedButton(
              child: new Text('Connexion'),
              onPressed: () {
                Navigator.of(context).pushNamed("/login");
              }),
          new RaisedButton(
              child: new Text('Inscription'),
              onPressed: () {
                //Navigator.of(context).pushNamed("/signup");
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (_) => SubscriptionView(),
                  ),
                );
              }),
        ],
      ),
    );

    return new Scaffold(
      appBar: null,
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("images/splashscreen.png"),
              fit: BoxFit.cover),
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Padding(padding: new EdgeInsets.only(bottom: 20.0), child: connectSignup)
          ],
        ),
      ),
    );
  }
}
