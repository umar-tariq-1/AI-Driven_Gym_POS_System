import 'package:flutter/material.dart';

class DataBox extends StatelessWidget {
  final Color color;
  final Color? textColor;
  final String? title;
  final String? subtitle;

  const DataBox(
      {super.key,
      required this.color,
      this.textColor,
      this.title,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.175),
        border: Border.all(color: color, width: 1.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.fromLTRB(17, 11, 0, 0),
              child: Text(title ?? '',
                  style: TextStyle(
                      color: textColor ?? color,
                      fontSize: 20.25,
                      fontFamily: 'RalewayMedium',
                      letterSpacing: -0.125))),
          Row(
            children: [
              const Spacer(),
              Container(
                  margin: EdgeInsets.fromLTRB(
                      0,
                      subtitle == 'No class' ? 16 : 10,
                      17,
                      subtitle == 'No class' ? 13 : 10),
                  child: Text(subtitle ?? '',
                      style: TextStyle(
                        color: textColor ?? color,
                        fontSize: subtitle == 'No class' ? 19 : 23,
                        fontFamily: 'RalewayMedium',
                      ))),
            ],
          ),
        ],
      ),
    );
  }
}
