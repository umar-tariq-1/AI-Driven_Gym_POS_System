import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final String? groupValue;
  final void Function(String?) onChanged;
  final List<String> options;

  const QuestionCard({
    super.key,
    required this.question,
    required this.groupValue,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 9, left: 25),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 18.5,
                  fontFamily: 'RalewaySemiBold',
                ),
              ),
            ),
          ),
          ...options.map((option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: groupValue,
                onChanged: onChanged,
              )),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
