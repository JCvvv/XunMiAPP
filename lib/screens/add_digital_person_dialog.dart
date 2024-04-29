import 'package:flutter/material.dart';
import '../models/digital_person.dart';
import '../models/message.dart';
import '../db/database_helper.dart';

class AddDigitalPersonDialog extends StatefulWidget {
  final Function(DigitalPerson) onSubmit;

  AddDigitalPersonDialog({required this.onSubmit});

  @override
  _AddDigitalPersonDialogState createState() => _AddDigitalPersonDialogState();
}

class _AddDigitalPersonDialogState extends State<AddDigitalPersonDialog> {
final TextEditingController _nameController = TextEditingController();
final TextEditingController _promptController = TextEditingController();
final DatabaseHelper _dbHelper = DatabaseHelper.instance;

String? _selectedRole;
List<String> roles = ['朋友', '情侣', '亲人', '咨询师'];
Map<String, String> roleToAvatar = {
  '朋友': 'assets/images/avatar1.png',
  '情侣': 'assets/images/avatar2.png',
  '亲人': 'assets/images/avatar3.png',
  '咨询师': 'assets/images/avatar4.png',
};

@override
Widget build(BuildContext context) {
  return AlertDialog(
    title: Text('添加数字人'),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(labelText: '角色'),
            items: roles.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedRole = newValue;
              });
            },
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '名字'),
          ),
          TextField(
            controller: _promptController,
            decoration: InputDecoration(labelText: '定制语句'),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text('取消'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text('添加'),
        onPressed: () async {
          if (_selectedRole != null && _nameController.text.isNotEmpty && _promptController.text.isNotEmpty) {
            final newPerson = DigitalPerson(
              role: _selectedRole!,
              name: _nameController.text,
              avatarUrl: roleToAvatar[_selectedRole]!,
              prompt: _promptController.text,
            );
            // 异步添加新的数字人并等待其完成
            int createdPersonId = await _dbHelper.insertDigitalPerson(newPerson);
            newPerson.id = createdPersonId;
            // 创建初始消息
            final initialMessage = Message(
                digitalPersonId: createdPersonId,
                content: "我是${_nameController.text}，我是您的数字${_selectedRole}",
                timestamp: DateTime.now(),
                isSystem: true  // 标记为系统消息
            );
            // 存储初始消息到数据库
            await _dbHelper.insertMessage(initialMessage);
            widget.onSubmit(newPerson);
            Navigator.of(context).pop();  // 关闭对话框
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('请填写所有字段')),
            );
          }
        },
      ),
    ],
  );
}
}