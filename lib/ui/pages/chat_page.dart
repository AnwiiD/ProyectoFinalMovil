import 'package:f_chat_template/data/model/local_message.dart';
import 'package:f_chat_template/ui/componentes/ChatBubble.dart';
import 'package:f_chat_template/ui/controllers/connection_controller.dart';
import 'package:f_chat_template/ui/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/chat_controller.dart';



// Widget con la interfaz del chat
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // controlador para el text input
  late TextEditingController _controller;
  // controlador para el sistema de scroll de la lista
  late ScrollController _scrollController;
  late String remoteUserUid;
  late String remoteEmail;

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
    remoteUserUid = argumentData[0];
    remoteEmail = argumentData[1];

    // instanciamos los controladores
    _controller = TextEditingController();
    _scrollController = ScrollController();

    // Le pedimos al chatController que se suscriba los chats entre los dos usuarios
    if (connectionController.connected.value) {
      chatController.subscribeToUpdated(remoteUserUid);
    } else {
      chatController.getLocalMessages(chatController.getChatKey(
          remoteUserUid, authenticationController.getUid()));
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
  return ChatBubble(
    message: element.msg,
    senderUid: element.senderUid,
    isCurrentUser: uid == element.senderUid,
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

  Future<void> _sendMsg(String text) async {
    // enviamos un nuevo mensaje usando el ChatController
    logInfo("Calling _sendMsg with $text");
    if (connectionController.connected.value) {
      await chatController.sendChat(remoteUserUid, text);
    } else {
      await Hive.box("messages").add(LocalMessage(
          chatController.getChatKey(
              remoteUserUid, authenticationController.getUid()),
          text,
          authenticationController.getUid(),
          "noname",
          0));
      chatController.messages.clear();
      chatController.getLocalMessages(chatController.getChatKey(
          remoteUserUid, authenticationController.getUid()));
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
            decoration: InputDecoration(
              labelText: 'Your message',
              labelStyle: const TextStyle(
                color: Color.fromARGB(255, 202, 196, 196),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 202, 196, 196),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 227, 225, 225),
                ),
              ),
              fillColor: const Color.fromARGB(255, 255, 255, 255),
              filled: true,
            ),
            onSubmitted: (value) {
              _sendMsg(_controller.text);
              _controller.clear();
            },
            controller: _controller,
            style: TextStyle(color: Colors.black), // Set text color
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 5.0),
        child: ElevatedButton(
          key: const Key('sendButton'),
          onPressed: () {
            _sendMsg(_controller.text);
            _controller.clear();
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: const Color.fromARGB(255, 129, 101, 234),
          ),
          child: const Padding(
            padding: EdgeInsets.all(13.0),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ),
      ),
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
        appBar: AppBar(title: Text("Chat with $remoteEmail"),backgroundColor: Colors.deepPurple[700],),
                backgroundColor: Colors.grey[100],

        body: Padding(
          padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 25.0),
          child: Column(
            children: [Expanded(flex: 4, child: _list()), _textInput()],
          ),
        ));
  }
}
