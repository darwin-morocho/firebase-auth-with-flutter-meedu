import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor, overlayColor;
  final TextStyle? textStyle;
  final double elevation, borderRadius;
  const RoundedButton({
    Key? key,
    this.onPressed,
    required this.text,
    this.backgroundColor,
    this.elevation = 7.0,
    this.borderRadius = 20.0,
    this.textStyle,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 18,
          ),
        ),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        overlayColor: MaterialStateProperty.all(overlayColor),
        elevation: MaterialStateProperty.all(elevation),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
