import 'package:flutter/material.dart';

class CustButton extends StatelessWidget {
  final VoidCallback pressAction;
  final Widget btnText;
  final Color btnColor;
  final double btnWidth;
  final double btnHeight;

  const CustButton(
      {super.key,
      required this.btnColor,
      required this.btnText,
      required this.btnHeight,
      required this.btnWidth,
      required this.pressAction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: btnHeight,
      width: btnWidth,
      child: ElevatedButton(
          onPressed: pressAction,
          style: ElevatedButton.styleFrom(backgroundColor: btnColor),
          child: btnText),
    );
  }
}
