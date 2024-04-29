## 寻觅数字人APP

### 项目说明

长话短说，一共要三个主页面：

1. 首页，类似 qq 聊天页面
2. 通讯录，类似手机通讯录
3. 个人中心，常见软件都有，随便写写就行

技术栈的话就是常见的 flutter 框架，多平台开发，下面我来讲讲项目文件。

各位同学可以先把环境配好，熟悉一下基础的 dart 语法，把基础的点击计数器这个案例看一下，下面我来讲一下我设计的框架。

众所周知，所有的页面和实现逻辑都在 lib 文件下面。

```
|-db
  -database_helper.dart 封装了基本的数据库操作函数
|-models
  -digital_person.dart 数字人实体类
  -message.dart 消息实体类
|-screens
  -home_screen.dart 主页
  -add_digital_person_dialog.dart 添加数字人
  -chat_screen.dart 具体的聊天页面
  -contacts_screen.dart 通讯录
  -profile_screen.dart 个人中心
|-main.dart 启动
```

### 页面功能

#### 主页

按照最后聊天的时间展示信息

![1](ReadmeImage\1.png)

添加数字人

![2](ReadmeImage\2.png)

填入信息

![3](ReadmeImage\3.png)

添加成功

![4](ReadmeImage\4.png)

#### 通讯录

按照首字母排序

![5](ReadmeImage\5.png)

#### 个人中心

![6](ReadmeImage\6.png)

可以更改头像和用户名/个人信息

![7](ReadmeImage\7.png)
