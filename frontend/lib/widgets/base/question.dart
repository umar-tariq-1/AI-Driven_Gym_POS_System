import 'package:flutter/material.dart';

class Question extends StatelessWidget {
  final int questionNumber;
  final EdgeInsets margin;
  final String questionText;

  const Question(
      {super.key,
      this.questionNumber = 0,
      this.margin = const EdgeInsets.all(0),
      required this.questionText});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Text(
          '${(questionNumber == 0) ? '' : '$questionNumber.  '}$questionText',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'RalewaySemiBold',
              color: Theme.of(context).primaryColor,
              fontSize: 25.25,
              letterSpacing: 0),
        ));
  }
}
