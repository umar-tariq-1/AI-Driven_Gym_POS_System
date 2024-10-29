import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/compound/custom_form.dart';

class EditQuiz extends StatefulWidget {
  const EditQuiz({super.key});

  static const routePath = '/edit-quiz';

  @override
  State<EditQuiz> createState() => _EditQuizState();
}

class _EditQuizState extends State<EditQuiz> {
  final controllers = {
    'question': TextEditingController(),
    'answer': TextEditingController(),
    'option1': TextEditingController(),
    'option2': TextEditingController(),
    'option3': TextEditingController()
  };

  void _formSubmitted(_) {
    Map data = {};
    List controllerKeys = controllers.keys.toList();
    for (var i in controllerKeys) {
      data[i] = controllers[i]!.text.trim();
    }
    for (var i in controllerKeys) {
      controllers[i]!.clear(); // This loop clears all text fields
    }
    FocusManager.instance.primaryFocus?.unfocus();
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3.5),
                ),
              ]),
              child: AppBar(
                toolbarHeight: 68,
                centerTitle: true,
                title: const Text(
                  "Edit Quiz",
                  style: TextStyle(
                    fontFamily: 'BeautifulPeople',
                    fontSize: 25.25,
                    letterSpacing: 1.3,
                    wordSpacing: 1.2,
                  ),
                ),
                leading: Builder(
                  builder: (context) {
                    return Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          color: appBarTextColor,
                          iconSize: 29,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ));
                  },
                ),
                backgroundColor: appBarColor,
                foregroundColor: appBarTextColor,
              ))),
      backgroundColor: backgroundColor,
      drawer: const CustomNavigationDrawer(
        active: "Edit Quiz",
      ),
      body: Stack(children: [
        GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Column(
          children: [
            CustomForm(
              inputFieldsList: [
                {
                  "label": "Question",
                  "controllerId": "question",
                  "controller": controllers['question'],
                  "color": Theme.of(context).primaryColor,
                },
                {
                  "label": "Answer",
                  "controllerId": "answer",
                  "controller": controllers['answer'],
                  "color": Colors.green.shade800,
                },
                {
                  "label": "Option 1",
                  "controllerId": "option1",
                  "controller": controllers['option1'],
                  "color": Colors.red.shade800,
                },
                {
                  "label": "Option 2",
                  "controllerId": "option2",
                  "controller": controllers['option2'],
                  "color": Colors.red.shade800,
                },
                {
                  "label": "Option 3",
                  "controllerId": "option3",
                  "controller": controllers['option3'],
                  "color": Colors.red.shade800,
                },
              ],
            ),
            CustomElevatedButton(
              buttonText: "Submit",
              onClick: _formSubmitted,
            )
          ],
        ),
      ]),
    );
  }
}
