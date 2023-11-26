import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String senderUid;
  final bool isCurrentUser;

  ChatBubble({required this.message, required this.senderUid, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    Color backgroundColor = isCurrentUser ? const Color.fromARGB(255, 129, 101, 234) : const Color.fromARGB(255, 213, 205, 244);
    Color fontColor = isCurrentUser ? Colors.white : const Color.fromARGB(255, 129, 101, 234);

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Card(
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: isCurrentUser ? const Radius.circular(15.0) : Radius.zero,
                      topRight: isCurrentUser ? Radius.zero : const Radius.circular(15.0),
                      bottomLeft: const Radius.circular(15.0),
                      bottomRight: const Radius.circular(15.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14.0, 14.0, 28.0, 14.0),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                
                  const Positioned(
                    bottom: 8.0,
                    right: 8.0,
                    child: Icon(
                      Icons.done_all,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}