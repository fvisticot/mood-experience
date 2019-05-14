import 'package:flutter/material.dart';
import 'dart:convert';

class GradientDescription {
  Color color1;
  Color color2;
  Color color3;
  String title;

  GradientDescription({@required this.title, @required this.color1, @required this.color2, this.color3});

  @override
  String toString() {
    return 'Gradient{color1: $color1, color2: $color2, color3: $color3, title: $title}';
  }

  Map<String, dynamic> toJson() =>
      {
        'title': title,
        'color1': color1.value,
        'color2': color2.value,
        'color3': color3?.value,
      };

  String toJsonString() {
    return jsonEncode(this);
  }

  GradientDescription.fromJsonString(String jsonString) {
    try {
      var json=jsonDecode(jsonString);
      title = json['title'];
      color1 = Color(json['color1']);
      color2 = Color(json['color2']);
      color3 = (json['color3']!=null)?Color(json['color3']):null;
    } catch (e) {

    }

  }

  GradientDescription.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        color1 = Color(json['color1']),
        color2 = Color(json['color2']),
        color3 = (json['color3']!=null)?Color(json['color3']):null;

}