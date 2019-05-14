import 'package:flutter/material.dart';
import 'mood_selector.dart';
import 'model/experience.dart';
import 'model/mood.dart';
import 'bloc_provider.dart';
import 'experience_bloc.dart';
import 'dart:math';
import 'experience_detail_view.dart';
import 'mood_indicator.dart';

//import 'package:vibrate/vibrate.dart';

class ExperienceView extends StatefulWidget {
  final Experience experience;

  ExperienceView({this.experience});

  @override
  createState() => ExperienceViewState(experience: experience);
}

class ExperienceViewState extends State<StatefulWidget> {
  final Experience experience;

  ExperienceViewState({this.experience});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var experienceBloc = BlocProvider.of<ExperienceBloc>(context);
    var moodStream = experienceBloc.moodStream;
    var membersStream = experienceBloc.membersStream;

    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (experience.type == ExperienceType.group)
                ? SizedBox(
                    height: 50.0, child: _buildMembersList(membersStream))
                : SizedBox(width: 0.0),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(height: 90.0, child: _buildMoodIndicator(moodStream)),
            SizedBox(
              height: 5.0,
            ),
            Expanded(flex: 1, child: _buildMoodSelector(moodStream)),
            SizedBox(
              height: 30.0,
            )
          ]),
    );
  }

  _buildMembersList(Stream<List<String>> membersStream) {
    return StreamBuilder(
        stream: membersStream,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return Text("No data");
          } else {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 5.0,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircleAvatar(
                      backgroundColor: Colors.brown.shade800,
                      child: Text('AL'),
                    ));
              },
            );
          }
        });
  }

  _buildMoodSelector(Stream<Mood> moodStream) {
    var experienceBloc = BlocProvider.of<ExperienceBloc>(context);
    return StreamBuilder<Mood>(
        stream: moodStream,
        builder: (BuildContext context, AsyncSnapshot<Mood> snapshot) {
          if (!snapshot.hasData) {
            return Center();
          } else {
            Mood mood = snapshot.data;
            if (mood.status == MoodStatus.inProgress) {
              return Center();
            } else {
              return MoodSelector(onChanged: (value) {
                //Vibrate.vibrate();
                experienceBloc.moodUpdate.add(
                    MoodUpdate(value: value, experienceId: experience.uid));
              });
            }
          }
        });
  }

  String _formatDouble(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  _buildRoundedButton2() {
    return Material(
      shape: CircleBorder(),
      color: Colors.transparent,
      child: InkWell(
        enableFeedback: true,
        borderRadius: BorderRadius.circular(60.0),
        highlightColor: Colors.white,
        splashColor: Colors.green,
        onTap: () => print("couc"),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('3.5',
                  style: TextStyle(color: Colors.white, fontSize: 34.0)),
            ),
          ),
        ),
      ),
    );
  }

  _buildRoundedButton() {
    return Center(
      child: new Container(
        height: 100.0,
        width: 100.0,
        child: new CustomPaint(
          foregroundPainter: new MyPainter(
              lineColor: Colors.amber,
              completeColor: Colors.blueAccent,
              completePercent: 70.0,
              width: 8.0),
          child: new Padding(
            padding: const EdgeInsets.all(5.0),
            child: new RaisedButton(
                color: Colors.purple,
                splashColor: Colors.blueAccent,
                shape: new CircleBorder(),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('2.0',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.0)),
                          Text(
                            '3.5',
                            style:
                                TextStyle(color: Colors.white, fontSize: 30.0),
                          ),
                          Text('5.0',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.0)),
                        ]),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExperienceDetailView(),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  _buildRoundedButtonOK1() {
    return RaisedButton(
        color: Colors.purple,
        splashColor: Colors.blueAccent,
        shape: new CircleBorder(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('2.0',
                      style: TextStyle(color: Colors.white, fontSize: 12.0)),
                  Text(
                    '3.5',
                    style: TextStyle(color: Colors.white, fontSize: 30.0),
                  ),
                  Text('5.0',
                      style: TextStyle(color: Colors.white, fontSize: 12.0)),
                ]),
          ),
        ),
        onPressed: () {
          print("coucou");
        });
  }

  _buildRoundedButtonOK() {
    return Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.indigoAccent, width: 4.0),
            color: Colors.indigo[900],
            shape: BoxShape.circle,
          ),
          child: InkWell(
            enableFeedback: true,
            //splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            //This keeps the splash effect within the circle
            borderRadius: BorderRadius.circular(
                1000.0), //Something large to ensure a circle
            onTap: () => print("couou"),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(1.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('2.0',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12.0)),
                      Text(
                        '3.5',
                        style: TextStyle(color: Colors.white, fontSize: 30.0),
                      ),
                      Text('5.0',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12.0)),
                    ]),
              ),
            ),
          ),
        ));
  }

  _buildMoodIndicator(Stream<Mood> moodStream) {
    return StreamBuilder<Mood>(
        stream: moodStream,
        builder: (BuildContext context, AsyncSnapshot<Mood> snapshot) {
          if (!snapshot.hasData) {
            return Text('Loading');
          } else {
            Mood mood = snapshot.data;
            if (mood.status == MoodStatus.inProgress) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                      )),
                  SizedBox(width: 10.0),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )
                ],
              );
            } else {
              return MoodIndicator(
                value: mood.value,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExperienceDetailView(),
                    ),
                  );
                },
              );
              //return Text(
              //  '${this._formatDouble(snapshot.data.value)}',
              //);
            }
          }
        });
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  MyPainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
