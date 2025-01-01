// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:frontend/theme/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader extends StatelessWidget {
  final bool isLoading;
  final Color? overlayColor;
  final Color? loaderColor;

  const Loader(
      {super.key,
      required this.isLoading,
      this.overlayColor,
      this.loaderColor});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        if (isLoading)
          Opacity(
            opacity: 0.8,
            child: ModalBarrier(
                dismissible: false,
                color: overlayColor ?? colorScheme.onPrimary),
          ),
        if (isLoading)
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.threeArchedCircle(
                color: loaderColor ?? colorScheme.inversePrimary,
                size: 50,
              ),
              Container(
                margin: const EdgeInsets.only(top: 14.5),
                padding: const EdgeInsets.only(left: 4),
                child: Text("Loading...",
                    style: TextStyle(
                        color: loaderColor ?? colorScheme.inversePrimary,
                        fontSize: 15,
                        // fontWeight: FontWeight.bold,
                        letterSpacing: 1.1)),
              ),
            ],
          )),
      ],
    );
  }
}
