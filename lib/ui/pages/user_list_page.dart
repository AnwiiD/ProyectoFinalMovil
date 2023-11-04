import 'package:f_chat_template/ui/controllers/chat_controller.dart';
import 'package:f_chat_template/ui/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../data/model/app_user.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/user_controller.dart';

// Widget donde se presentan los usuarios con los que se puede comenzar un chat
class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage>
    with SingleTickerProviderStateMixin {
  // obtenemos la instancia de los controladores
  AuthenticationController authenticationController = Get.find();
  ChatController chatController = Get.find();
  UserController userController = Get.find();
  late TabController _tabController;

  @override
  void initState() {
    // le decimos al userController que se suscriba a los streams
    userController.start();
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

  Widget _item(AppUser element) {
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
          element.email,
        ),
        subtitle: Text(element.uid),
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
          return _item(element);
        },
      );
    });
  }

  Widget groupList() {
    // Un widget con La lista de los usuarios con una validación para cuándo la misma este vacia
    // la lista de usuarios la obtenemos del userController
    return GetX<UserController>(builder: (controller) {
      if (userController.users.length == 0) {
        return const Center(
          child: Text('No groups'),
        );
      }
      return ListView.builder(
        itemCount: userController.users.length,
        itemBuilder: (context, index) {
          var element = userController.users[index];
          return _item(element);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // Number of selectable sections
        child: Scaffold(
          appBar: AppBar(
            title: Text('Bienvenido ${authenticationController.userEmail()}'),
            actions: [
              Row(children: [
                Text('Cerrar sesión'),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    authenticationController.logout();
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
          body: TabBarView(
            children: [
              Center(child: chatList()),
              Center(child: groupList()),
            ],
          ),
          floatingActionButton:
              _buildFloatingActionButton(_tabController.index),
        ));
  }
}

Widget _buildFloatingActionButton(int tabIndex) {
  if (tabIndex == 0) {
    return FloatingActionButton(
      onPressed: () {
        newChat();
      },
      child: Icon(Icons.chat),
    );
  } else {
    return FloatingActionButton(
      onPressed: () {
        newGroup();
      },
      child: Icon(Icons.add),
    );
  }
}

void newChat() {}

void newGroup() {}
