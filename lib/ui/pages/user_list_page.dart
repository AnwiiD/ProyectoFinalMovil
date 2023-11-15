import 'package:f_chat_template/data/model/app_group.dart';
import 'package:f_chat_template/ui/controllers/chat_controller.dart';
import 'package:f_chat_template/ui/controllers/group_controller.dart';
import 'package:f_chat_template/ui/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../data/model/app_user.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/user_controller.dart';
import 'chat_group_page.dart';

// Widget donde se presentan los usuarios con los que se puede comenzar un chat
class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage>
    with SingleTickerProviderStateMixin {
  AuthenticationController authenticationController = Get.find();
  ChatController chatController = Get.find();
  UserController userController = Get.find();
  GroupController groupController = Get.find();

  TextEditingController groupNameController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    // le decimos al userController que se suscriba a los streams
    userController.start();
    groupController.start();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // le decimos al userController que se cierre los streams
    userController.stop();
    super.dispose();
  }

  _logout() async {
    try {
      await authenticationController.logout();
    } catch (e) {
      logError(e);
    }
  }

  Widget _group(AppGroup element) {
    // Widget usado en la lista de los usuarios
    // mostramos el correo y uid
    return Card(
      elevation: 5.0, // Add elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Set the border radius
      ),
      color: Colors.lightBlueAccent,
      margin: const EdgeInsets.all(4.0),
      child: ListTile(
        onTap: () {
          if (_userInGroup(element)) {
            Get.to(ChatGroupPage(), arguments: [
            authenticationController.getUid(),
            element.gid,
            element.name]);
          } else {
            _joinGroupDialog(context, element);
          }
        },
        title: Text(
          element.name,
        ),
        subtitle: Text(element.users.toString()),
      ),
    );
  }

  Widget _chat(AppUser element) {
    // Widget usado en la lista de los usuarios
    // mostramos el correo y uid
    return Card(
      elevation: 5.0, // Add elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Set the border radius
      ),
      color: Colors.lightBlueAccent,
      margin: const EdgeInsets.all(4.0),
      child: ListTile(
        onTap: () {
          Get.to(() => const ChatPage(), arguments: [
            element.uid,
            element.email,
          ]);
        },
        title: Text(
          element.name,
        ),
        subtitle: Text(element.email),
      ),
    );
  }

  Widget chatList() {
    // Un widget con La lista de los usuarios con una validación para cuándo la misma este vacia
    // la lista de usuarios la obtenemos del userController
    return GetX<UserController>(builder: (controller) {
      if (userController.users.length == 0) {
        return const Center(
          child: Text('No users'),
        );
      }
      return ListView.builder(
        itemCount: userController.users.length,
        itemBuilder: (context, index) {
          var element = userController.users[index];
          return _chat(element);
        },
      );
    });
  }

  Widget groupList() {
    // Un widget con La lista de los usuarios con una validación para cuándo la misma este vacia
    // la lista de usuarios la obtenemos del userController
    return GetX<GroupController>(builder: (controller) {
      if (groupController.groups.length == 0) {
        return const Center(
          child: Text('No groups'),
        );
      }
      return ListView.builder(
        itemCount: groupController.groups.length,
        itemBuilder: (context, index) {
          var element = groupController.groups[index];
          return _group(element);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido ${getName()}'),
        actions: [
          Row(children: [
            const Text('Cerrar sesión'),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _logout();
              },
            ),
          ])
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chats', icon: Icon(Icons.chat)),
            Tab(text: 'Grupos', icon: Icon(Icons.group)),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: TabBarView(
          controller: _tabController,
          children: [
            Scaffold(
              body: Center(child: chatList()),
              floatingActionButton: _buildFloatingActionButton(0, context),
            ),
            Scaffold(
              body: Center(child: groupList()),
              floatingActionButton: _buildFloatingActionButton(1, context),
            ),
          ],
        ),
      ),
    );
  }

  void _joinGroupDialog(BuildContext context, element) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Unirse a este Grupo: ${element.name}?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                authenticationController.joinGroup(element.gid);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Unirse al grupo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _createGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Crear Grupo?'),
          content: TextField(
            controller: groupNameController,
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                String inputText = groupNameController.text;
                var groupid = await groupController.createGroup(inputText);
                authenticationController.joinGroup(groupid);
              },
              child: const Text('Crear Grupo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton(int tabIndex, context) {
    if (tabIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          _createGroupDialog(context);
        },
        child: const Icon(Icons.add),
      );
    } else {
      return Container();
    }
  }

  bool _userInGroup(AppGroup element) {
    var user = authenticationController.getUid();
    for (var users in element.users.keys) {
      if (users == user) {
        return true;
      }
    }
    return false;
  }
  
  getName() async{
    String name = await authenticationController.userName();
    return name;
  }
}
