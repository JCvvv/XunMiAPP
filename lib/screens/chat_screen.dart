import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/message.dart';
import '../models/digital_person.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  final DigitalPerson digitalPerson;

  const ChatScreen({Key? key, required this.digitalPerson}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  void loadMessages() async {
    messages = await _dbHelper.getMessagesForDigitalPerson(widget.digitalPerson.id!);
    setState(() {});
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // 用户发送的消息
      final newMessage = Message(
        digitalPersonId: widget.digitalPerson.id!,
        content: _messageController.text,
        timestamp: DateTime.now(),
        isSystem: false,
      );
      await _dbHelper.insertMessage(newMessage);

      _messageController.clear();

      // 定义一个回复列表
      List<String> replies = [
        "您就是大名鼎鼎的赏月章学姐吗",
        "学姐，你的开发环境配置好了吗",
        "学姐，还有很多任务没有完成，您还不能休息",
        "学姐，我们会按时完成开发的，会吗？",
        "学姐，app的美化工作就交给您啦"
      ];
      // 随机选择一个回复
      String randomReply = replies[Random().nextInt(replies.length)];
      // 系统自动回复的消息
      final systemReply = Message(
        digitalPersonId: widget.digitalPerson.id!,
        content: randomReply, // 使用随机选择的回复
        timestamp: DateTime.now(),
        isSystem: true, // 标记为系统消息
      );
      await _dbHelper.insertMessage(systemReply);
      loadMessages(); // 刷新列表以显示新消息和系统回复
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与数字人 ${widget.digitalPerson.name} 的聊天'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 在这里传递true，表示首页需要刷新
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isSystem = message.isSystem; // 系统消息指的是数字人发送的消息
                DateTime timestamp = message.timestamp;
                String formattedTime = DateFormat('MM-dd HH:mm').format(timestamp); // 格式化时间

                return Padding(
                  padding: EdgeInsets.only(
                    left: isSystem ? 16.0 : 50.0, // 系统消息距离左侧更近
                    right: isSystem ? 50.0 : 16.0, // 用户消息距离右侧更近
                  ),
                  child: Column(
                    crossAxisAlignment: isSystem ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: isSystem ? MainAxisAlignment.start : MainAxisAlignment.end,
                        children: [
                          if (isSystem) ...[
                            CircleAvatar(
                              backgroundImage: AssetImage(widget.digitalPerson.avatarUrl), // 数字人头像
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(message.content, softWrap: true),
                              ),
                            ),
                          ],
                          if (!isSystem) ...[
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                margin: EdgeInsets.symmetric(vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(message.content, softWrap: true),
                              ),
                            ),
                            SizedBox(width: 8),
                            CircleAvatar(
                              backgroundImage: AssetImage("assets/images/user.png"), // 用户头像
                            ),
                          ],
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 2.0,
                          left: isSystem ? 64.0 : 0, // 调整时间文本的位置
                          right: !isSystem ? 64.0 : 0,
                        ),
                        child: Text(
                          formattedTime,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          textAlign: isSystem ? TextAlign.left : TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: '输入您的信息'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}