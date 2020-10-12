import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final bool isThemeDark;
  final double size;
  final Function onPressed;
  final bool pressed;
  final IconData icon;

  CircleIconButton({this.isThemeDark, this.size = 30.0, this.icon = Icons.clear, this.onPressed, this.pressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment(0.0, 0.0), // all centered
          children: <Widget>[
            pressed ? Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isThemeDark ? Colors.white12 :  Colors.grey[100]),
            ):Container(),
            pressed ? Icon(
              icon,
              size: size * 0.6, // 60% width for icon
            ): Container()
          ],
        )
      )
    );
  }
}

