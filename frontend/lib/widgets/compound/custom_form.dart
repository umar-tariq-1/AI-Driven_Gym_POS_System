// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import '../base/input_field.dart';

class CustomForm extends StatelessWidget {
  final Map<String, TextEditingController> controllers = {};
  List<Map<String, dynamic>> inputFieldsList = [];
  final List<Widget> inputFieldsWidgets = [];
  final EdgeInsets margin;

  CustomForm(
      {super.key,
      required this.inputFieldsList,
      this.margin = const EdgeInsets.all(0)}) {
    for (var i = 0; i < inputFieldsList.length; i++) {
      controllers[inputFieldsList[i]['controllerId']] =
          inputFieldsList[i]['controller'];
      inputFieldsWidgets.add(CustomInputField(
        controller: controllers[inputFieldsList[i]['controllerId']]!,
        label: inputFieldsList[i]['label'],
        color: inputFieldsList[i]['color'],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...inputFieldsWidgets,
          ]),
    );
  }
}
