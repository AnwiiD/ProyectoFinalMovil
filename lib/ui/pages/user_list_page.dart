import 'package:f_chat_template/data/model/app_group.dart';
import 'package:f_chat_template/ui/controllers/chat_controller.dart';
import 'package:f_chat_template/ui/controllers/connection_controller.dart';
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
  ConnectionController connectionController = Get.find();

  TextEditingController groupNameController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    // le decimos al userController que se suscriba a los streams
    userController.start();
    groupController.start();
    authenticationController.getName();
    super.initState();
    if (connectionController.connected.value) {
      loadCache();
    }
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
  return Card(
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: const BorderSide(color: Color.fromARGB(255, 129, 101, 234)),
    ),
    color: Colors.white,
    margin: const EdgeInsets.all(0.0),
    child: ListTile(
      onTap: () {
        if (_userInGroup(element)) {
          Get.to(const ChatGroupPage(), arguments: [
            authenticationController.getUid(),
            element.gid,
            element.name,
          ]);
        } else {
          _joinGroupDialog(context, element);
        }
      },
      title: Text(
        element.name,
        style: TextStyle(
          color: Colors.grey[800],
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        getUsernames(element),
        style: const TextStyle(
          color: Color.fromARGB(255, 129, 101, 234),
          fontSize: 16.0,
        ),
      ),
      leading: Icon(Icons.group, size: 40.0), // Use the group icon
    ),
  );
}


  Widget _chat(AppUser element) {
    // Widget usado en la lista de los usuarios
    // mostramos el correo y uid
    return Card(
      elevation: 5.0, // Add elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0), // Set the border radius
        side: const BorderSide(color: Color.fromARGB(255, 129, 101, 234)), // Add a border to the card
      ),
      color: Colors.white, // Change the card color to white
      margin: const EdgeInsets.all(0.0),
      child: ListTile(
        leading: Icon(Icons.account_circle, size: 40.0),// Use a random image for testing
          // backgroundImage: AssetImage('assets/images/user.png'), // Or use an image of your choice
        
        onTap: () {
          Get.to(() => const ChatPage(), arguments: [
            element.uid,
            element.email,
          ]);
        },
        title: Text(
          element.name,
          style: TextStyle( // Change the text style
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(element.email,
          style: const TextStyle( // Change the text style
            color: Color.fromARGB(255, 129, 101, 234),
          ),
        ),
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
    return Obx(() => Scaffold(
          appBar: AppBar(
            backgroundColor: connectionController.connected.value
                ? Colors.deepPurple[700]
                : Colors.deepPurple[700],
            title: Obx(() => Text(
                'Bienvenido ${authenticationController.name.value} ${getConnectivity()}')),
            actions: [
              Row(children: [
                const Text('Cerrar sesión'),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    _logout();
                  },
                ),
              ]),
              IconButton(
  icon: Icon(
    connectionController.connected.value
        ? Icons.wifi
        : Icons.wifi_off,
  ),
  onPressed: () {
    connectionController.connected.value =
        !connectionController.connected.value;
  },
),
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
        ));
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
          if (connectionController.connected.value) {
            _createGroupDialog(context);
          } else {
            Get.snackbar(
              "Groups error",
              'Necesitas internet para crear un grupo',
              icon: const Icon(Icons.person, color: Colors.red),
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        backgroundColor: const Color.fromARGB(255, 129, 101, 234), // Set the purple background color
  child: Icon(Icons.add),
      
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

  String getUsernames(AppGroup element) {
    String userlist = "Integrantes: ";
    for (var user in element.users.values) {
      userlist = userlist + user["name"] + " / ";
    }
    return userlist;
  }

  void loadCache() {
    chatController.loadMessages();
  }

  getConnectivity() {
    return connectionController.connected.value
        ? "desde Remoto"
        : "desde Local";
  }
}
