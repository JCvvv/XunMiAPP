import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../db/database_helper.dart';
import '../models/digital_person.dart';
import 'package:lpinyin/lpinyin.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>{
  List<DigitalPerson> digitalPersons = []; // 用于存储从数据库加载的数字人信息
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Map<String, List<DigitalPerson>> groupedContacts = {}; // 分组联系人

  @override
  void initState() {
    super.initState();
    loadDigitalPersons(); // 加载并分组数字人信息
  }

  void loadDigitalPersons() async {
    List<DigitalPerson> persons = await _dbHelper.getSortedDigitalPersons();
    setState(() {
      digitalPersons = persons;
      groupedContacts = _groupPersonsByFirstLetter(persons);
    });
  }

  Map<String, List<DigitalPerson>> _groupPersonsByFirstLetter(List<DigitalPerson> persons) {
    Map<String, List<DigitalPerson>> map = {};
    for (DigitalPerson person in persons) {
      // 获取名字的首字母
      String pinyin = PinyinHelper.getPinyinE(person.name.substring(0, 1));
      String firstLetter = pinyin.substring(0, 1).toUpperCase();
      if (!RegExp(r'[A-Z]').hasMatch(firstLetter)) {
        firstLetter = '#'; // 非字母开头的名字归类到其他
      }
      if (!map.containsKey(firstLetter)) {
        map[firstLetter] = [];
      }
      map[firstLetter]!.add(person);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通讯录'),
      ),
      body: CustomScrollView(
        slivers: groupedContacts.entries.map((entry) {
          return SliverStickyHeader(
            header: Container(
              height: 50.0,
              color: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                entry.key,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  DigitalPerson person = entry.value[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(person.avatarUrl), // 确保这是有效的资源路径
                    ),
                    title: Text(person.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(digitalPerson: person),
                        ),
                      );
                    },
                  );
                },
                childCount: entry.value.length,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}