// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/main.dart';
import 'dart:convert';
import 'dart:math';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/base/question.dart';
import 'package:frontend/widgets/base/round_icon_button.dart';
import 'package:frontend/widgets/base/timer.dart';
import 'package:frontend/widgets/base/loader.dart';
// import 'package:flutter_fgbg/flutter_fgbg.dart';

class AttemptQuiz extends StatefulWidget {
  final BuildContext mainContext;
  final void Function(String) changePage;

  static const routePath = '/attempt-quiz';

  const AttemptQuiz(
      {super.key, required this.mainContext, required this.changePage});

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<AttemptQuiz> with WidgetsBindingObserver {
  int currentQuestionIndex = 0;
  int activeButton = -1;
  List<int> questionIndexes = [];
  List<int> optionIndexes = [];
  Map<String, List<dynamic>> questions = {};
  int score = 0;
  String currentState = "Show Questions";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // The app has resumed (gained focus)
      print("Gotcha! Hahahahaha");
    } else if (state == AppLifecycleState.paused) {
      // The app has paused (lost focus)
    }
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      isLoading = true;
      // errorMessage = null; // Clear any previous error messages
    });

    var url =
        'https://opentdb.com/api.php?amount=5&category=21&difficulty=easy&type=multiple';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          questions = {};
          for (var i = 0; i < data['results'].length; i++) {
            String question = data['results'][i]['question'].toString();
            question = question
                .replaceAll('&#039;', "'")
                .replaceAll('&amp;', "&")
                .replaceAll('&quot;', '"');
            List<dynamic> options = data['results'][i]['incorrect_answers'];
            options.insert(0, data['results'][i]['correct_answer']);
            for (var j = 0; j < 4; j++) {
              options[j] = options[j]
                  .toString()
                  .replaceAll('&#039;', "'")
                  .replaceAll('&amp;', "&")
                  .replaceAll('&quot;', '"');
            }
            questions[question] = options;
          }
          questionIndexes = _getRandomNumbers(0, questions.length - 1);
          optionIndexes = _getRandomNumbers(0, 3);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _goHome('');
        // errorMessage = 'Error: ${e.toString()}'; // Display the error message
      });
    }
  }

  List<int> _getRandomNumbers(int m, int n) {
    List<int> numbers = [];
    for (int i = m; i <= n; i++) {
      numbers.add(i);
    }
    Random random = Random();
    numbers.shuffle(random);
    Random random2 = Random();
    numbers.shuffle(random2);
    return numbers;
  }

  void _optionSelected(String selectedOption) {
    setState(() {
      activeButton = questions.values
          .toList()[questionIndexes[currentQuestionIndex]]
          .indexOf(selectedOption);
    });
  }

  void _nextQuestion() {
    if (activeButton != -1) {
      if (questions.values.toList()[questionIndexes[currentQuestionIndex]]
              [activeButton] ==
          questions.values.toList()[questionIndexes[currentQuestionIndex]][0]) {
        score++;
      }
    }
    setState(() {
      if (currentQuestionIndex != questions.keys.toList().length - 1) {
        currentQuestionIndex++;
        optionIndexes = _getRandomNumbers(0, 3);
        activeButton = -1;
      } else {
        setState(() {
          currentState = "Show Score";
          currentQuestionIndex = 0;
          activeButton = -1;
        });
      }
    });
  }

  // void _handleAppLostFocus(FGBGType state) {
  //   if (state == FGBGType.background) {
  //     print('cheating');
  //   }
  // }

  void _goHome(_) {
    if (ModalRoute.of(context)?.settings.name != MyApp.routePath) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).popAndPushNamed('/');
    widget.changePage("Home Page");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        /* child: FGBGNotifier(
            onEvent: _handleAppLostFocus, */
        child: Scaffold(
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
                        "Attempt Quiz",
                        style: TextStyle(
                          fontFamily: 'BeautifulPeople',
                          fontSize: 25.25,
                          letterSpacing: 1.2,
                          wordSpacing: 1.2,
                        ),
                      ),
                      leading: currentState == 'Show Score'
                          ? Builder(
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
                            )
                          : const Icon(null),
                      backgroundColor: appBarColor,
                      foregroundColor: appBarTextColor,
                    ))),
            backgroundColor: backgroundColor,
            drawer: const CustomNavigationDrawer(
              active: "Attempt Quiz",
            ),
            body: Stack(
              children: [
                if (currentState == "Show Questions")
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (questions.isNotEmpty)
                                    Question(
                                      questionNumber: currentQuestionIndex + 1,
                                      questionText: questions.keys.toList()[
                                          questionIndexes[
                                              currentQuestionIndex]],
                                    ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  ...optionIndexes.map((index) {
                                    if (questions.isNotEmpty) {
                                      return CustomElevatedButton(
                                        key: ValueKey(index),
                                        buttonText: questions.values.toList()[
                                            questionIndexes[
                                                currentQuestionIndex]][index],
                                        onClick: (option) =>
                                            _optionSelected(option),
                                        active: index == activeButton,
                                        minWidth: 235,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                                  if (questions.isNotEmpty)
                                    RoundIconButton(
                                      icon: const Icon(
                                          Icons.arrow_forward_rounded),
                                      onClick: _nextQuestion,
                                      disabled: activeButton == -1,
                                      margin: const EdgeInsets.only(
                                          top: 45, bottom: 40),
                                    ),
                                  if (questions.isNotEmpty)
                                    TimerWidget(
                                      durationInSeconds: 1000,
                                      onTimerComplete: () => setState(() {
                                        currentState = 'Show Score';
                                      }),
                                    ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                if (currentState == "Show Score")
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      Center(
                        child: Question(
                          questionText: "You scored $score/${questions.length}",
                        ),
                      ),
                      const Spacer(),
                      CustomElevatedButton(
                        buttonText: "Main Page",
                        onClick: _goHome,
                        fontSize: 18.5,
                        height: 13,
                        minWidth: 220,
                        leadingIcon: const Icon(
                          Icons.subdirectory_arrow_left_rounded,
                          size: 27,
                        ),
                        // active: true,
                      ),
                    ],
                  ),
                if (isLoading)
                  Center(
                      child: Loader(
                    isLoading: isLoading,
                    overlayColor: Colors.white,
                  )),
              ],
            )) /* ) */);
  }
}
