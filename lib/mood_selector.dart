import 'package:flutter/material.dart';

typedef CircleButtonTapCallback = void Function(double value);

class CircleButton extends StatelessWidget {
  final CircleButtonTapCallback onTap;
  final IconData iconData;
  final double size;
  final double value;

  const CircleButton(
      {Key key, this.onTap, this.iconData, this.size, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: CircleBorder(),
      color: Colors.transparent,
      child: InkWell(
        enableFeedback: true,
        borderRadius: BorderRadius.circular(60.0),
        highlightColor: Colors.white,
        splashColor: Colors.green,
        onTap: () => onTap(value),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            iconData,
            size: size,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class MoodSelector extends StatelessWidget {
  final ValueChanged<double> onChanged;

  MoodSelector({this.onChanged});

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.sentiment_very_satisfied,
      Icons.sentiment_satisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_very_dissatisfied
    ];

    List<CircleButton> buttons = List<CircleButton>();
    double value = 5.0;
    for (IconData iconData in icons) {
      buttons.add(CircleButton(
          value: value,
          size: 80.0,
          iconData: iconData,
          onTap: (value) => _iconPressed(value)));
      value -= 1;
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: buttons);
  }

  _iconPressed(double value) {
    onChanged(value);
  }
}
