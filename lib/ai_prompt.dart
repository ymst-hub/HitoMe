import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'DBHelper.dart';

class AiPrompt extends StatefulWidget {
  const AiPrompt({Key? key, required this.person, required this.promptDisplay}) : super(key: key);
  final Map<String, dynamic> person;
  final String promptDisplay;
  @override
  _AiPromptState createState() => _AiPromptState();
}

class _AiPromptState extends State<AiPrompt>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('AI用プロンプト'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(  // SingleChildScrollViewを追加
              child: Column(
                children: [
                  SizedBox(height: 60,),
                  Text(
                    "下記の文言でAIに相談してください。",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 60,),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(widget.promptDisplay),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: widget.promptDisplay));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('クリップボードにコピーしました'),
            ),
          );
        },
        tooltip: 'コピー',
        child: const Icon(Icons.copy),
      )
    );
  }
}