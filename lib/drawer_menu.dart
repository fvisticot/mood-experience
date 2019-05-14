import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/user_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';

import 'drawer_menu_presenter.dart';
import 'model/gradient_description.dart';

class DrawerMenu extends StatefulWidget {
  @override
  createState() => new DrawerMenuState();
}

class DrawerMenuState extends State<DrawerMenu> {
  List<GradientDescription> _gradients = <GradientDescription>[
    GradientDescription(
        title: 'Chity Chity Bang Bang',
        color1: Color(0xff007991),
        color2: Color(0xff78ffd6)),
    GradientDescription(
        title: 'Summer', color1: Color(0xff22c1c3), color2: Color(0xfffdbb2d)),
    GradientDescription(
        title: 'Shifter', color1: Color(0xffbc4e9c), color2: Color(0xfff80759)),
    GradientDescription(
        title: 'Tranquil',
        color1: Color(0xffEECDA3),
        color2: Color(0xffEF629F)),
    GradientDescription(
        title: 'Master Card',
        color1: Color(0xfff46b45),
        color2: Color(0xffeea849)),
    GradientDescription(
        title: 'Peach', color1: Color(0xffED4264), color2: Color(0xffFFEDBC)),
    //GradientDescription(title: '', color1: Color(0xff), color2: Color(0xff)),
  ];

  PackageInfo _packageInfo = new PackageInfo(
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  String _userPhotoUrl;
  DrawerMenuPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = new DrawerMenuPresenter();
    _initPackageInfo();
    UserUtils().get('userId').then((userId) {
      _initPhotoUrl(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          new DrawerHeader(
            decoration: new BoxDecoration(
              color: Colors.blue,
            ),
            child: new Center(
              child: new Column(children: [
                _buildTakeImageButton(),
                new Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: new Text('Click picture to change',
                        textScaleFactor: 1.1))
              ]),
            ),
          ),
          ListTile(
              title: Text('Theme selection'),
              onTap: () => _displayThemeSelection()),
          ListTile(
            title: new Text('Disconnect'),
            leading: new Icon(Icons.exit_to_app),
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text('Really want to exit'),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            new UserUtils().setLogged(false.toString());
                            Navigator.of(context)
                                .pushReplacementNamed("/connect_signup");
                          },
                        )
                      ],
                    );
                  });
              //
              //
            },
          ),
          ListTile(
            title: new Text(
                'Version: ${_packageInfo.version} (${_packageInfo.buildNumber})'),
          ),
        ],
      ),
    );
  }

  _displayThemeSelection() async {
    List<Widget> gradientWidgets =
        _gradients.map((GradientDescription gradient) {
      return SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, gradient);
        },
        child: Text(gradient.title),
      );
    }).toList();

    var selectedGradient = await showDialog<GradientDescription>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Theme'),
            children: gradientWidgets,
          );
        });
    print('${selectedGradient.toJson()}');
    String jsonValue = selectedGradient.toJsonString();
    UserUtils().set('GRADIENT', jsonValue);
  }

  _getImage() async {
    File pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
    print(pickedImageFile);
    String userPhotoUrl = await _presenter.setUserPhoto(pickedImageFile);
    setState(() {
      _userPhotoUrl = userPhotoUrl;
    });
  }

  _buildTakeImageButton() {
    if (_userPhotoUrl == null) {
      return new IconButton(
          iconSize: 80.0,
          icon: new Icon(Icons.add_a_photo),
          onPressed: () {
            _getImage();
          });
    } else {
      return new GestureDetector(
        onTap: () {
          _getImage();
        },
        child: new Container(
          width: 100.0,
          height: 100.0,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: new CachedNetworkImageProvider(_userPhotoUrl))),
        ),
      );
    }
  }

  _initPhotoUrl(userId) async {
    var userPhotoUrl = await _presenter.getUserPhotoUrl(userId);
    setState(() {
      _userPhotoUrl = userPhotoUrl;
    });
  }

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
}
