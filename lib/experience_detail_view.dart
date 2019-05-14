import 'package:flutter/material.dart';


class ExperienceDetailView extends StatefulWidget{

  @override
  createState() => ExperienceDetailViewState();
}

class ExperienceDetailViewState extends State<StatefulWidget> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(elevation: 0.0, title: Text('Test')),body: Center(child: Text("coucou"),));
  }
}