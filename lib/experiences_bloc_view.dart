import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/experience.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'user_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'user_utils.dart';
import 'model/gradient_description.dart';
import 'drawer_menu.dart';
import 'experiences_slider.dart';

import 'bloc_provider.dart';
import 'experiences_bloc.dart';
import 'package:flushbar/flushbar.dart';

enum ActionType { shareExperience, deleteExperience, joinExperience, createExperience, leaveExperience }

class ActionChoice {
  String title;
  IconData icon;
  ActionType type;
  ActionChoice({@required this.type, @required this.title, this.icon});

  @override
  String toString() {
    return 'ActionChoice{title: $title, icon: $icon}';
  }
}

class ExperiencesBlocView extends StatefulWidget {
  @override
  createState() => ExperiencesBlocViewState();
}

class ExperiencesBlocViewState extends State<ExperiencesBlocView> {
  String _userId;
  GradientDescription _gradientDescription;
  Experience _selectedExperience;
  BlocProvider<ExperiencesBloc> _blocProvider;

  List<ActionChoice> _experienceActionChoices = <ActionChoice>[
    ActionChoice(type: ActionType.shareExperience, title: 'Share Experience', icon: Icons.share),
    ActionChoice(type: ActionType.deleteExperience, title: 'Remove Experience', icon: Icons.delete),
    ActionChoice(type: ActionType.leaveExperience, title: 'Leave Experience', icon: Icons.call_missed_outgoing),
  ];

  List<ActionChoice> _experienceAddActionChoices = <ActionChoice>[
    ActionChoice(type: ActionType.createExperience, title: 'Add Experience', icon: Icons.create),
    ActionChoice(type: ActionType.joinExperience, title: 'Join Experience', icon: Icons.group),
  ];

  @override
  void initState() {
    super.initState();
    _initUserExperiences();
  }

  _initUserExperiences() async {
    final userId = await UserUtils().get('userId');

    String gradientJson= await UserUtils().get('GRADIENT');
    _gradientDescription = GradientDescription(title: 'Chity Chity Bang Bang', color1: Color(0xff007991), color2: Color(0xff78ffd6));
    if (gradientJson!= null) {
      _gradientDescription=GradientDescription.fromJsonString(gradientJson);
    }

    _blocProvider = BlocProvider<ExperiencesBloc>(
        bloc: ExperiencesBloc(), child: ExperiencesSlider(userId: userId));

    setState(() {
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context){
    if (_userId == null) {
      return Scaffold(body: Center(child: Text("Loading experiences")));
    }
    print('Rebuilding entire view.');
    var experiencesBloc = _blocProvider.bloc;


    return Scaffold(
      appBar:  AppBar(
          elevation: 0.0,
          backgroundColor: _gradientDescription.color1,
          title: StreamBuilder<Experience>(
              stream: experiencesBloc.experienceStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("No Data");
                } else {
                  _selectedExperience = snapshot.data;
                  return Text('${_selectedExperience.name}');
                }
              }),
          actions: <Widget>[
         IconButton(
          icon: new Icon(Icons.more_horiz),
        onPressed: () {
          _displayExperienceActionsSheet();
        })
          ]),
      drawer: DrawerMenu(),
      body: Container(
        decoration: BoxDecoration(
            //https://uigradients.com/#CoolSky
            gradient: LinearGradient(
                //colors: [Color(0xffFF0099), Color(0xff493240)],
              colors: [_gradientDescription.color1, _gradientDescription.color2],
                begin: Alignment.topCenter, // new
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp)),
        child: _blocProvider,
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            _displayAddExperienceActionsSheet();
          }),
    );
  }

  _displayAddExperienceActionsSheet() {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      List<Widget> widgets = _experienceAddActionChoices.map((ActionChoice choice) {
        return ListTile(leading: Icon(choice.icon), title: Text(choice.title), onTap: () => _selectedAction(choice),);
      }).toList();

      return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,children: widgets);
    });
  }


  _displayExperienceActionsSheet() {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      List<Widget> widgets = _experienceActionChoices.map((ActionChoice choice) {
        return ListTile(leading: Icon(choice.icon), title: Text(choice.title), onTap: () => _selectedAction(choice),);
      }).toList();

      return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,children: widgets);
    });
  }

  _selectedAction(ActionChoice choice) {
    print(choice);
    Navigator.pop(context);
    switch (choice.type) {
      case ActionType.shareExperience: {
        _displayExperienceCode(_selectedExperience.uid);
        break;
      }
      case ActionType.deleteExperience: {
        _deleteExperience();
        break;
      }
      case ActionType.joinExperience : {
        _joinExperience();
        break;
      }
      case ActionType.createExperience: {
        _createExperience();
        break;
      }
      case ActionType.leaveExperience: {
        _leaveExperience();
        break;
      }
      default:
         break;
    }
  }

  _leaveExperience() {
    Flushbar()
      ..title = "Hey Ninja"
      ..message = "Lorem Ipsum is simply dummy text of the printing and typesetting industry"
      ..duration = Duration(seconds: 3)
      ..show(context);
  }

  _deleteExperience() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Really want to delete Experience ${_selectedExperience.name} ?'),
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
                  _blocProvider.bloc.action.add(ExperiencesAction(
                      userId: _userId,
                      type: ExperiencesActionType.removeExperienceAction,
                      experience: _selectedExperience));
                },
              )
            ],
          );
        });
  }
  /*
  _displayAddMenu() async {
    switch (await showDialog<ActionType>(
      context: context,
      builder: (context) => SimpleDialog(
            title: const Text('Add/Join experience.'),
            children: <Widget>[
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ActionType.createExperience);
                },
                child: const Text('Create Experience'),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ActionType.joinExperience);
                },
                child: const Text('Join Experience'),
              ),
            ],
          ),
    )) {
      case ActionType.createExperience:
        _createExperience();
        break;
      case ActionType.joinExperience:
        await _scan();
        break;
    }
  }
  */

  _createExperience() {
    final TextEditingController _controller = new TextEditingController();

    showDialog<Null>(
      context: context,
      builder: (context) => SimpleDialog(
            title: const Text(
              'Experience',
              textAlign: TextAlign.center,
              maxLines: 1,
              textScaleFactor: 0.8,
            ),
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration:
                      new InputDecoration(labelText: "Nom", hintText: "Nom"),
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                ),
              ),
              new Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: new RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      String experienceName = _controller.text;
                      if (experienceName.length > 0) {
                        _blocProvider.bloc.action.add(ExperiencesAction(
                            userId: _userId,
                            type: ExperiencesActionType.addExperienceAction,
                            experience: Experience(
                                name: this.capitalize(_controller.text),
                                type: ExperienceType.group)));
                      }
                    },
                    child: new Text("Créer"),
                    color: Colors.primaries[0],
                  )),
            ],
          ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future _joinExperience() async {
    try {
      String barcode = await BarcodeScanner.scan();
      return barcode;
    } on PlatformException catch (e) {
      ;
    } on FormatException {
      ;
    } catch (e) {
      ;
    }
  }

  @override
  onCreateExperienceSuccess(String experienceId) {
    _displayExperienceCode(experienceId);
  }

  _displayExperienceCode(String experienceId) {
    showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Share with other participants',
            textAlign: TextAlign.center,
            maxLines: 1,
            textScaleFactor: 0.8,
          ),
          children: <Widget>[
            Container(
              height: 250.0,
              width: 250.0,
              child: Center(
                child: QrImage(
                  data: experienceId,
                  size: 250.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
