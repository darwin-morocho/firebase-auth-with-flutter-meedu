import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/rounded_button.dart';

class NumericKeyboard extends StatelessWidget {
  final void Function(String text) onValue;
  final VoidCallback onDelete;
  const NumericKeyboard({
    Key? key,
    required this.onValue,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfffafafa),
      child: SafeArea(
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: const EdgeInsets.all(15),
          childAspectRatio: 16 / 7,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...List.generate(
              9,
              (index) => _Button(
                text: "${index + 1}",
                onPressed: () {
                  onValue("${index + 1}");
                },
              ),
            ),
            Container(),
            _Button(
              text: "0",
              onPressed: () {
                onValue("0");
              },
            ),
            _Button(
              text: "⌫",
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _Button({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      text: text,
      backgroundColor: Colors.white,
      overlayColor: Colors.lightBlue,
      elevation: 0,
      borderRadius: 8,
      textStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 22,
        height: 1.5,
        fontWeight: FontWeight.bold,
      ),
      onPressed: onPressed,
    );
  }
}
