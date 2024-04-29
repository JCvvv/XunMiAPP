import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/digital_person.dart';
import '../models/message.dart';
import 'add_digital_person_dialog.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
List<DigitalPerson> digitalPersons = []; // 用于存储从数据库加载的数字人信息
Map<int, String> latestMessages = {}; // 用于存储每个数字人的最新消息内容
final DatabaseHelper _dbHelper = DatabaseHelper.instance;

@override
void initState() {
  super.initState();
  loadDigitalPersons(); // 加载数字人信息
}

void loadDigitalPersons() async {
  digitalPersons = await _dbHelper.getAllDigitalPersons();
  for (DigitalPerson person in digitalPersons) {
    Message? latestMessage = await _dbHelper.getLatestMessageForDigitalPerson(person.id!);
    setState(() {
      latestMessages[person.id!] = latestMessage?.content ?? "无消息";
    });
  }
}

void reloadData() async {
  digitalPersons = await _dbHelper.getAllDigitalPersons();  // 重新从数据库获取所有数字人
  latestMessages.clear();
  for (DigitalPerson person in digitalPersons) {
    // 获取最新的消息
    Message? latestMessage = await _dbHelper.getLatestMessageForDigitalPerson(person.id!);
    latestMessages[person.id!] = latestMessage?.content ?? "无消息";
  }
  setState(() {});  // 更新状态以刷新UI
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('首页'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddDigitalPersonDialog(onSubmit: (DigitalPerson person) {
                  reloadData();
                });
              }
          ),
        )
      ],
    ),
    body: ListView.builder(
      itemCount: digitalPersons.length,
      itemBuilder: (context, index) {
        DigitalPerson person = digitalPersons[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(person.avatarUrl),
            ),
            title: Text(person.name),
            subtitle: Text(latestMessages[person.id!] ?? "加载中..."),
            onTap: () async {
              // 推送到聊天页面，并等待返回结果
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(digitalPerson: person),
                ),
              );
              // 检查从聊天页面返回的结果
              if (result == true) {
                reloadData();  // 如果需要，重新加载数据
              }
            },
          ),
        );
      },
    ),
  );
}
}