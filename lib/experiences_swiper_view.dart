import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/firestore_ds.dart';
import 'package:flutter_app/model/experience.dart';
import 'package:flutter_app/model/mood.dart';
import 'package:flutter_app/user_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';

import 'drawer_menu.dart';
import 'experiences_viewmodel.dart';
//import 'package:vibrate/vibrate.dart';

enum AddMenuActionType { createExperience, joinExperience }

enum ActionType { displayFirst, createExperience, deleteExperience, none }

class ExperiencesSwiperView extends StatefulWidget {
  @override
  createState() => ExperiencesSwiperViewState();
}

class ExperiencesSwiperViewState extends State<ExperiencesSwiperView> {
  ExperiencesViewModel _experiencesViewModel = ExperiencesViewModel();
  String _userId;
  Experience _selectedExperience;
  Stream _userExperiencesStream;
  Stream _experiencesInfoStream;
  StreamSubscription _subscription;
  SwiperController _swiperController = SwiperController();
  int _currentExperienceIndex = 0;

  @override
  void initState() {
    super.initState();
    _initUserExperiences();
  }

  _initUserExperiences() async {
    final userId = await UserUtils().get('userId');
    _userExperiencesStream =
        _experiencesViewModel.userExperiencesStream(userId);
    //_experiencesInfoStream = _experiencesViewModel.experiencesInfoStream();

    /*
    _experiencesInfoStream.listen((ExperiencesInfo experiencesInfo) {
      _currentExperienceIndex = experiencesInfo.currentExperienceIndex;
      print("Updating currentPageIndex in view to $_currentExperienceIndex");
    });
    */

    setState(() {
      _userId = userId;
    });
  }

  _iconPressed(num moodValue) async {
    _experiencesViewModel.setMood(
        experience: _selectedExperience, mood: moodValue);
  }

  _buildMoodIndicator(Experience experience) {
    final stream =
        _experiencesViewModel.registerTodaysExperienceMoodStream(experience);
    return StreamBuilder<Mood>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return CircularProgressIndicator();
          } else {
            Mood mood = snapshot.data;
            return Text('${mood.value}',
                style: TextStyle(color: Colors.red, fontSize: 60.0));
          }
        });
  }

  _buildMoodSelector() {
    //print('Build MoodSelector.');
    final Column moodSelector = Column(children: <Widget>[
      new IconButton(
          icon: new Icon(Icons.sentiment_very_satisfied),
          iconSize: 48.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(5);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_very_satisfied),
          iconSize: 24.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(5);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_satisfied),
          iconSize: 48.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(4);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_satisfied),
          iconSize: 24.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(4);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_neutral),
          iconSize: 48.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(3);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_neutral),
          iconSize: 24.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(3);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_dissatisfied),
          iconSize: 48.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(2);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_dissatisfied),
          iconSize: 24.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(2);
          }),
      new IconButton(
          icon: new Icon(Icons.sentiment_very_dissatisfied),
          iconSize: 48.0,
          alignment: Alignment.center,
          color: Colors.blue,
          highlightColor: Colors.red,
          onPressed: () {
            _iconPressed(1);
          }),
    ]);
    return moodSelector;
  }

  @override
  Widget build(BuildContext context) {
    /*if (_userId == null) {
      return Scaffold(body: Center(child: Text("Loading experiences")));
    }
    print('Rebuilding entire view.');

    return Scaffold(
      appBar: new AppBar(
          title: StreamBuilder<ExperiencesInfo>(
              stream: _experiencesInfoStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //print("Title: first display: ${snapshot.data.firstDisplay}");
                  //print('==> updating title with expe ${snapshot.data.currentExperience.name}');
                  _selectedExperience = snapshot.data.currentExperience;
                  return Text(snapshot.data.currentExperience.name);
                  //return Text("tempo");
                } else {
                  return Center(child: Text("no data"));
                }
              }),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.share),
                onPressed: () {
                  _displayExperienceCode(_selectedExperience.uid);
                })
          ]),
      drawer: new DrawerMenu(),
      body: new Container(
        padding: new EdgeInsets.only(
          top: 16.0,
        ),
        decoration: new BoxDecoration(color: Colors.yellow),
        child: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<ExperiencesInfo>(
                    stream: _userExperiencesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return _createExperiencesPagesWidget(snapshot.data);
                      } else {
                        return Center(child: Text("No data"));
                      }
                    })),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            _displayAddMenu();
          }),
    );
    */
  }

  /*
  _createExperiencesPagesWidget(ExperiencesInfo experiencesInfo) {
    var experiences = experiencesInfo.experiences;
    print('Creating ExperiencesPagesWidget: ${experiencesInfo} and CurrentPageIndex: $_currentExperienceIndex');
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Column(children: <Widget>[
              _buildMoodIndicator(experiences[index]),
              _buildMoodSelector(),
            ]));
      },
      key: Key(DateTime.now().toString()),
      controller: _swiperController,
      index: _currentExperienceIndex,
      indicatorLayout: PageIndicatorLayout.COLOR,
      autoplay: false,
      itemCount: experiences.length,
      pagination: SwiperPagination(builder: SwiperPagination.fraction),
      control: SwiperControl(),
      onIndexChanged: (index) {
        print("OnIndexChanged: $index");
        _experiencesViewModel.experienceIndexSink.add(index);
        },
      //viewportFraction: 0.8,
      //scale: 0.9,
    );
  }
  */

  _displayAddMenu() async {
    switch (await showDialog<AddMenuActionType>(
      context: context,
      builder: (context) => SimpleDialog(
            title: const Text('Select assignment'),
            children: <Widget>[
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AddMenuActionType.createExperience);
                },
                child: const Text('Create Experience'),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AddMenuActionType.joinExperience);
                },
                child: const Text('Join Experience'),
              ),
            ],
          ),
    )) {
      case AddMenuActionType.createExperience:
        _createExperience();
        break;
      case AddMenuActionType.joinExperience:
        String experienceId = await _scan();
        //print('Scaned Experience: ${experienceId}');
        //_experiencesViewModel.subscribeToGroupExperience(_userId, experienceId);
        break;
    }
  }

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
                  autofocus: false,
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
                        /*_subscription = _experiencesInfoStream.listen((data) {
                          print("===>coucou fred");
                          _swiperController.move(
                              _currentExperienceIndex);
                          _subscription.cancel();
                        });
                        */
                        _experiencesViewModel.createGroupExperience(
                            _userId, experienceName);

                      }
                    },
                    child: new Text("Créer"),
                    color: Colors.primaries[0],
                  )),
            ],
          ),
    );
  }

  Future _scan() async {
    _experiencesViewModel.unsubscribeToGroupExperience(
        _userId, _selectedExperience.uid);
    /*try {
      print('scan');
      String barcode = await BarcodeScanner.scan();
      //Vibrate.vibrate();
      return barcode;
    } on PlatformException catch (e) {
      ;
    } on FormatException {
      ;
    } catch (e) {
      ;
    }*/
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
