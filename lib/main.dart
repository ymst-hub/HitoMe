import 'package:flutter/material.dart';

import 'DBHelper.dart';
import 'personal_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: "あなたの人間関係"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  var people = <Map<String, dynamic>>[];
  var ids = <String>[];
  var names = <String>[];

  @override
  void initState() {
    _createList();
    super.initState();
  }

  void _addPerson() {
    _textController = TextEditingController();
    _focusNode = FocusNode();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: const InputDecoration(hintText: "名前"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('追加'),
              onPressed: () {
                //入力がない場合、ユーザーに通知する
                if (_textController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('名前を入力してください'),
                    ),
                  );
                  return;
                }
                DBHelper().insertPerson(_textController.text);
                _textController.clear();
                _createList();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    ).then((_) {
      // ダイアログが閉じられたときにリソースをクリーンアップします
      _textController.dispose();
      _focusNode.dispose();
    });

    // ダイアログが開いたときにテキストフィールドを自動的に選択します
    _focusNode.requestFocus();
    _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
  }

  //リストを作成する
  Future _createList() async {
    people = await _getPeople();
    setState(() {
      //peopleのデータをitemsにstringのリストとして格納する
      names = people.map((person) => person['name'].toString()).toList();
      ids = people.map((person) => person['id'].toString()).toList();
    });
  }

  //personテーブルから全てのデータを取得する
  Future<List<Map<String, dynamic>>> _getPeople() async {
    return await DBHelper().getAllPerson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        children: listViewPerson(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPerson,
        tooltip: 'add',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> listViewPerson() {
    return <Widget>[
      Expanded(
        child: ListView.builder(
          itemCount: names.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  title: Text(names[index]),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PersonalDetail(person: people[index])),
                    );
                    setState(() {
                      _createList();
                    });
                  },
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    ];
  }
}
