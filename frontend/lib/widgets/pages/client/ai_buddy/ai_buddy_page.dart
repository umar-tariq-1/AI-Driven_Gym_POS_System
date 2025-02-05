import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/states/trainer.dart';
import 'package:frontend/theme/theme.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AIBuddyPage extends StatefulWidget {
  const AIBuddyPage({super.key});
  static const routePath = '/client/fitness-plans';

  @override
  State<AIBuddyPage> createState() => _AIBuddyPageState();
}

class _AIBuddyPageState extends State<AIBuddyPage> {
  final apiKey = 'AIzaSyDx2zU_4XxRRy-7JrZm4XAfZOozY6mfZhk';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "AI Buddy",
        backgroundColor: appBarColor,
        foregroundColor: appBarTextColor,
      ),
      drawer: const CustomNavigationDrawer(
        active: 'AI Buddy',
        accType: "Client",
      ),
      backgroundColor: Colors.grey.shade100,
      body: GetBuilder<TrainerController>(builder: (controller) {
        return ChatWidget(apiKey: apiKey);
      }),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    required this.apiKey,
    super.key,
  });

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];
  bool _loading = false;
  bool _sendEnabled = false;
  final initialContext = Content(
    'user',
    [
      TextPart('''
You are a fitness and gym expert who specializes in providing accurate, evidence-based fitness, diet, nutrition and gym-related advice.

Role and Responsibilities:
- Provide expert guidance on workout routines, exercise techniques, and fitness planning
- Answer questions about fitness and gym topics like nutrition, diet, muscle groups, training principles, recommend excercises based on requirements etc.
- Offer safety tips and proper form recommendations
- Help with workout scheduling and progression

Response Guidelines:
- Always provide concise and practical answers
- Donot give long explanations until specifically asked to
- Use clear headings and formatting when appropriate
- Include bullet points or numbered lists for step-by-step instructions
- Focus exclusively on fitness, diet, nutrition and gym-related topics
- When recommending excercises, at the end also ask to perform under supervision of trainer if beginner, for correct form
- Politely decline to answer questions outside of expertise

If asked about other topics, apologize and deny to answer.

'''),
    ],
  );

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: widget.apiKey,
    );
    _chat = _model.startChat(
      history: [initialContext],
    );
    getUserData();
  }

  void getUserData() async {
    var userData = await SecureStorage().getItem("userData");
    setState(() {
      _generatedContent.add((
        image: null,
        text: "Hi ${userData['firstName']}!\n\nWhat can I help you with?",
        fromUser: false
      ));
    });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colorScheme.primary,
        ),
      ),
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Ask me anything about fitness...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colorScheme.primary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: colorScheme.primary,
        ),
      ),
    );

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: widget.apiKey.isNotEmpty
                    ? ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (context, idx) {
                          final content = _generatedContent[idx];
                          return MessageWidget(
                            text: content.text,
                            image: content.image,
                            isFromUser: content.fromUser,
                          );
                        },
                        itemCount: _generatedContent.length,
                      )
                    : ListView(
                        children: const [
                          Text(
                            'Sorry, can\'t response you back.',
                          ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.5, 20, 0, 25),
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: TextField(
                        onChanged: (value) {
                          if (value.trim() == "") {
                            setState(() {
                              _sendEnabled = false;
                            });
                          } else {
                            setState(() {
                              _sendEnabled = true;
                            });
                          }
                        },
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: textFieldDecoration,
                        controller: _textController,
                        onSubmitted: _sendChatMessage,
                      ),
                    ),
                    const SizedBox.square(dimension: 12.5),
                    if (!_loading)
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () async {
                            if (_sendEnabled) {
                              HapticFeedback.mediumImpact();
                              _sendChatMessage(_textController.text);
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            size: 28,
                            color: _sendEnabled
                                ? colorScheme.inversePrimary
                                : Colors.grey,
                          ),
                        ),
                      )
                    else
                      Expanded(
                          flex: 1,
                          child: Center(
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: colorScheme.inversePrimary,
                                strokeWidth: 3,
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    _generatedContent.add((image: null, text: message, fromUser: true));
    try {
      final responses = _chat.sendMessageStream(Content.text(message));
      _generatedContent.add((image: null, text: "...", fromUser: false));
      bool first = true;
      FocusScope.of(context).unfocus();
      await for (final response in responses) {
        // print(response.text);
        if (response.text != null) {
          setState(() {
            _generatedContent[_generatedContent.length - 1] = (
              image: null,
              text: first
                  ? response.text!
                  : _generatedContent.last.text! + response.text!,
              fromUser: false
            );
          });
        }
        _scrollDown();
        first = false;
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _sendEnabled = false;
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
        _sendEnabled = false;
      });
      // _textFieldFocus.requestFocus();
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  final Image? image;
  final String? text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    Color textColor = isFromUser ? Colors.white : colorScheme.inversePrimary;

    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9),
                decoration: BoxDecoration(
                  color: isFromUser ? colorScheme.inversePrimary : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Shadow color
                      spreadRadius: 2, // Spread of the shadow
                      blurRadius: 5, // Blur radius
                      offset: const Offset(0, 3), // Offset for shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                    20,
                    15,
                    15,
                    isFromUser
                        ? 15
                        : text == "..."
                            ? 15
                            : 55),
                margin: EdgeInsets.only(bottom: isFromUser ? 12.5 : 17.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text case final text?)
                      MarkdownBody(
                        data: text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          a: TextStyle(
                              color: colorScheme.primary,
                              inherit: true), // Links
                          p: TextStyle(
                              color: textColor,
                              fontSize: 16.5,
                              inherit: true), // Paragraph text
                          h1: TextStyle(
                              color: textColor, inherit: true), // Heading 1
                          h2: TextStyle(
                              color: textColor, inherit: true), // Heading 2
                          h3: TextStyle(
                              color: textColor, inherit: true), // Heading 3
                          strong: TextStyle(
                              color: textColor, inherit: true), // Bold text
                          em: TextStyle(
                              color: textColor, inherit: true), // Italics
                          blockquote: TextStyle(
                              color: textColor,
                              inherit: true), // Blockquote text
                        ),
                      ),
                    if (image case final image?) image,
                  ],
                ),
              ),
              if (!isFromUser && text != "...")
                Positioned(
                  bottom: 23.75,
                  right: 7.5,
                  child: IconButton(
                    icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Text copied to clipboard!'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
