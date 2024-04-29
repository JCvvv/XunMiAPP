import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '用户名';
  String signature = '用户信息详情';
  File? avatarFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File newImage = File(pickedFile.path);
      await _saveImage(newImage);
      setState(() {
        avatarFile = newImage;
      });
    }
  }

  Future<void> _saveImage(File newImage) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final File newAvatarFile = File('$path/userImage.png');
    newImage.copy(newAvatarFile.path);
    setState(() {
      avatarFile = newAvatarFile;
    });
  }

  Future<void> _loadImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final savedImage = File('$path/userImage.png');
    if (await savedImage.exists()) {
      setState(() {
        avatarFile = savedImage;
      });
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: username);
        TextEditingController signatureController = TextEditingController(text: signature);
        return AlertDialog(
          title: Text('编辑资料'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '用户名'),
              ),
              TextField(
                controller: signatureController,
                decoration: InputDecoration(labelText: '个性签名'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () {
                setState(() {
                  username = nameController.text;
                  signature = signatureController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showToast() {
    Fluttertoast.showToast(
        msg: "正在开发",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundImage: avatarFile != null
                    ? FileImage(avatarFile!)
                    : AssetImage('assets/images/user.png') as ImageProvider,
              ),
            ),
            title: Text(username),
            subtitle: Text(signature),
            onTap: _editProfile,
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('联系我们'),
              onTap: showToast,
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('关于产品'),
              onTap: showToast,
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.article),
              title: Text('服务条款'),
              onTap: showToast, // 使用同样的Toast消息提示正在开发
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('隐私政策'),
              onTap: showToast, // 使用同样的Toast消息提示正在开发
            ),
          ),
        ],
      ),
    );
  }
}
