import 'package:flutter/material.dart';
import 'package:frontend/theme/theme.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/custom_outlined_button.dart';

class CustomConfirmationDialog {
  static void show(BuildContext context,
      {String title = "Confirm",
      String message = "Are you sure?",
      String yesText = "Yes",
      String noText = "No",
      VoidCallback? yesCallback,
      VoidCallback? noCallback,
      VoidCallback? then}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: AlertDialog(
            actionsPadding:
                const EdgeInsets.only(left: 24.0, right: 18.0, bottom: 14.0),
            insetPadding: EdgeInsets.zero,
            backgroundColor: colorScheme.surface,
            title: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider()
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            actions: [
              CustomOutlinedButton(
                buttonText: noText,
                onClick: noCallback ?? () => {},
                minWidth: 87,
                transitionColor: true,
                color: colorScheme.error,
                fontSize: 14.7,
                height: 0,
              ),
              CustomElevatedButton(
                buttonText: yesText,
                fontSize: 14.7,
                height: 2,
                minWidth: 118,
                onClick: yesCallback ?? () => {},
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (then == null) {
        return;
      }
      then();
    });
  }
}
