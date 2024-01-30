import 'package:flutter/material.dart';

import 'DBHelper.dart';
import 'ai_prompt.dart';

// タブ用のEnum
enum TabItem { will, appearance, personality, done }

class PersonalDetail extends StatefulWidget {
  const PersonalDetail({Key? key, required this.person}) : super(key: key);
  final Map<String, dynamic> person;

  @override
  PersonalDetailState createState() => PersonalDetailState();
}

class PersonalDetailState extends State<PersonalDetail> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  var selector = TabItem.will;
  var person = <Map<String, dynamic>>[];
  var personsDetail = <List<String>>[];
  var personSerial = <List<String>>[];
  var promptHead = "あなたは下記の特徴をもつ人物になりきって今後の返答を行ってください。\n";
  var promptDisplay = "";
  List<String> tabName = ["約束", "外見", "内面", "思い出"]; //タブ名称

  Future<void> _createList() async {
    //DBからpersonに紐づく全てのデータを取得する
    final will = await DBHelper().getWillById(widget.person['id']);
    final done = await DBHelper().getDoneById(widget.person['id']);
    final appearance = await DBHelper().getAppearanceById(widget.person['id']);
    final personality =
        await DBHelper().getPersonalityById(widget.person['id']);

    //それぞれをリスト形式に変更する
    var willList = will.map((will) => will['things'].toString()).toList();
    var doneList = done.map((done) => done['things'].toString()).toList();
    var appearanceList = appearance
        .map((appearance) => appearance['things'].toString())
        .toList();
    var personalityList = personality
        .map((personality) => personality['things'].toString())
        .toList();

    var willSerialList = will.map((will) => will['Serial'].toString()).toList();
    var doneSerialList = done.map((done) => done['Serial'].toString()).toList();
    var appearanceSerialList = appearance
        .map((appearance) => appearance['Serial'].toString())
        .toList();
    var personalitySerialList = personality
        .map((personality) => personality['Serial'].toString())
        .toList();

    setState(() {
      //ListをそれぞれpersonDetailに格納する
      personsDetail = [willList, appearanceList, personalityList, doneList];
      personSerial = [
        willSerialList,
        appearanceSerialList,
        personalitySerialList,
        doneSerialList
      ];
    });
  }

  void _addAlert() {
    _textController = TextEditingController();
    _focusNode = FocusNode();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: const InputDecoration(hintText: "内容"),
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
                      content: Text('未入力です'),
                    ),
                  );
                  return;
                }
                //タブに応じてDBにデータを追加する
                switch (selector) {
                  case TabItem.will:
                    DBHelper()
                        .insertWill(widget.person['id'], _textController.text);
                    break;
                  case TabItem.appearance:
                    DBHelper().insertAppearance(
                        widget.person['id'], _textController.text);
                    break;
                  case TabItem.personality:
                    DBHelper().insertPersonality(
                        widget.person['id'], _textController.text);
                    break;
                  case TabItem.done:
                    DBHelper()
                        .insertDone(widget.person['id'], _textController.text);
                    break;
                  default:
                    //デフォルトをwillに設定しておく
                    DBHelper()
                        .insertWill(widget.person['id'], _textController.text);
                    break;
                }
                _createList();
                _textController.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    ).then((_) {
      _textController.dispose();
      _focusNode.dispose();
    });
    // ダイアログが開いたときにテキストフィールドを自動的に選択します
    _focusNode.requestFocus();
    _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length));
  }

  Future<void> _deleteAll() async {
    //personに紐づく全てのデータを削除する
    await DBHelper().deleteWillById(widget.person['id']);
    await DBHelper().deleteDoneById(widget.person['id']);
    await DBHelper().deleteAppearanceById(widget.person['id']);
    await DBHelper().deletePersonalityById(widget.person['id']);
    await DBHelper().deletePersonById(widget.person['id']);
    //前の画面に戻る
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteThings(var index) async {
    //アラートダイアログを表示する
    _deleteAlert(index);
  }

  void _deleteAlert(var index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('本当に削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: const Text('削除'),
              onPressed: () {
                //selectorに応じてDBからデータを削除する
                switch (selector) {
                  case TabItem.will:
                    DBHelper().deleteWillBySerial(
                        int.parse(personSerial[selector.index][index]));
                    break;
                  case TabItem.appearance:
                    DBHelper().deleteAppearanceBySerial(
                        int.parse(personSerial[selector.index][index]));
                    break;
                  case TabItem.personality:
                    DBHelper().deletePersonalityBySerial(
                        int.parse(personSerial[selector.index][index]));
                    break;
                  case TabItem.done:
                    DBHelper().deleteDoneBySerial(
                        int.parse(personSerial[selector.index][index]));
                    break;
                  default:
                    //デフォルトをwillに設定しておく
                    DBHelper().deleteWillBySerial(
                        int.parse(personSerial[selector.index][index]));
                    break;
                }
                //リストを再作成する
                _createList();

                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  //promptを生成する
  void _makePrompt() {
    //初期化
    promptDisplay = "";
    //selectorに応じてpromptを作成する
    promptDisplay = promptHead;
    for (var i = 0; i < personsDetail[selector.index].length; i++) {
      promptDisplay += "・${personsDetail[selector.index][i]}\n";
    }
    //prompt表示ページに移動する
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AiPrompt(person: widget.person, promptDisplay: promptDisplay)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.person['name']}の${tabName[selector.index]}'),
        actions: [
          IconButton(
            onPressed: _deleteAll,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _createList(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  return ListView.builder(
                    itemCount: personsDetail[selector.index].length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text((personsDetail[selector.index][index]
                                .toString())),
                            onTap: () => _deleteThings(index),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  );
                }
            ),
          )
        ],
      ),
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _makePrompt,
            tooltip: 'prompt生成',
            child: const Icon(Icons.psychology),
          ),
          const SizedBox(height: 50),
          FloatingActionButton(
            onPressed: _addAlert,
            tooltip: 'add',
            child: const Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(.60),
        currentIndex: selector.index,
        onTap: (value) {
          setState(() {
            switch (value) {
              case 0:
                selector = TabItem.will;
                break;
              case 1:
                selector = TabItem.appearance;
                break;
              case 2:
                selector = TabItem.personality;
                break;
              case 3:
                selector = TabItem.done;
                break;
              default:
                selector = TabItem.will; //デフォルトをwillに設定しておく
            }
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.update), label: "約束"),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: "外見"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "内面"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "思い出")
        ],
      ),
    );
  }
}
