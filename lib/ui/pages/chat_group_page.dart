import 'package:f_chat_template/data/model/local_message.dart';
import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:f_chat_template/ui/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/chat_controller.dart';

// Widget con la interfaz del chat
class ChatGroupPage extends StatefulWidget {
  const ChatGroupPage({Key? key}) : super(key: key);
  @override
  State<ChatGroupPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatGroupPage> {
  // controlador para el text input
  late TextEditingController _controller;
  // controlador para el sistema de scroll de la lista
  late ScrollController _scrollController;
  late String remoteGroup;
  late String remoteUserUid;
  late String remoteGroupName;

  // obtenemos los parámetros del sistema de navegación
  dynamic argumentData = Get.arguments;

  // obtenemos las instancias de los controladores
  ChatController chatController = Get.find();
  AuthenticationController authenticationController = Get.find();
  LocationController locationController = Get.find();
  ConnectionController connectionController = Get.find();

  @override
  void initState() {
    super.initState();
    // obtenemos los datos del usuario con el cual se va a iniciar el chat de los argumentos
    remoteGroup = argumentData[1];
    remoteGroupName = argumentData[2];
    remoteUserUid = argumentData[0];
    // instanciamos los controladores
    _controller = TextEditingController();
    _scrollController = ScrollController();

    // Le pedimos al chatController que se suscriba los chats entre los dos usuarios
    if (connectionController.connected.value) {
      chatController.subscribeToUpdatedGroup(remoteGroup);
    } else {
      chatController.getLocalGroupMessages(remoteGroup);
    }
  }

  @override
  void dispose() {
    // proceso de limpieza
    _controller.dispose();
    _scrollController.dispose();
    chatController.unsubscribe();
    chatController.messages.clear();
    super.dispose();
  }

  Widget _item(element, int posicion, String uid) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      // cambiamos el color dependiendo de quién mandó el usuario
      color: uid == element.senderUid ? Colors.yellow[200] : Colors.grey[300],
      child: ListTile(
        title: Text(
          element.senderName,
          style: TextStyle(fontSize: 15.0, color: Colors.blue[900]),
          textAlign:
              uid == element.senderUid ? TextAlign.right : TextAlign.left,
        ),
        subtitle: Text(
          element.msg,
          style: const TextStyle(fontSize: 20.0),
          textAlign:
              uid == element.senderUid ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }

  Widget _list() {
    String uid = authenticationController.getUid();
    // Escuchamos la lista de mensajes entre los dos usuarios usando el ChatController
    return GetX<ChatController>(builder: (controller) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      return ListView.builder(
        itemCount: chatController.messages.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          var element = chatController.messages[index];
          return _item(element, index, uid);
        },
      );
    });
  }

  Future<void> _sendGroupMsg(String text) async {
    // enviamos un nuevo mensaje usando el ChatController
    logInfo("Calling _sendMsg with $text");
    if (connectionController.connected.value) {
      await chatController.sendGroupChat(remoteUserUid, remoteGroup, text,
          authenticationController.name.value);
    } else {
      await Hive.box("messages").add(LocalMessage(remoteGroup, text,
          remoteUserUid, authenticationController.name.value, 0));
      chatController.messages.clear();
      chatController.getLocalGroupMessages(remoteGroup);
    }
  }

  Widget _textInput() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 5.0, top: 5.0),
            child: TextField(
              key: const Key('MsgTextField'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your message',
              ),
              onSubmitted: (value) {
                _sendGroupMsg(_controller.text);
                _controller.clear();
              },
              controller: _controller,
            ),
          ),
        ),
        TextButton(
            key: const Key('sendButton'),
            child: const Text('Send'),
            onPressed: () {
              _sendGroupMsg(_controller.text);
              _controller.clear();
            })
      ],
    );
  }

  _scrollToEnd() async {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    return Scaffold(
        appBar: AppBar(title: Text("Chat in $remoteGroupName")),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 25.0),
          child: Column(
            children: [Expanded(flex: 4, child: _list()), _textInput()],
          ),
        ));
  }
}
