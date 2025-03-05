// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gym_ease/theme/theme.dart';

class TimerWidget extends StatefulWidget {
  final int durationInSeconds;
  final Function onTimerComplete;
  final EdgeInsets margin;
  final String beforeText;

  const TimerWidget(
      {super.key,
      required this.durationInSeconds,
      this.beforeText = "Time left: ",
      this.margin = const EdgeInsets.all(0),
      required this.onTimerComplete});

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationInSeconds;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          widget.onTimerComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Text(
        '${widget.beforeText}$_secondsRemaining seconds',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontFamily: "RalewayMedium",
          fontSize: 14,
        ),
      ),
    );
  }
}
