import 'package:flutter/material.dart';

class Rules extends StatefulWidget {
const Rules({Key? key})
    : super(key: key);

@override
RulesState createState() => RulesState();
}

class RulesState extends State<Rules> {
  String rules = '''これが利用規約です'''; // 利用規約の内容を全て記載（別出しも別途考慮）'''だと改行をよしなにしてくれる
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('利用規約'),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // SingleChildScrollViewを追加
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                          rules,
                          overflow: TextOverflow.ellipsis
                      ),
                    )
                  ],
                ),
              ),
            )
          ]
        ),
    );
  }
}