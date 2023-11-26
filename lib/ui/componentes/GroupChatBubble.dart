import 'package:flutter/material.dart';

class GroupChatBubble extends StatelessWidget {
  final String senderName;
  final String message;
  final bool isCurrentUser;

  GroupChatBubble({required this.senderName, required this.message, required this.isCurrentUser});

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
                      topLeft: isCurrentUser ? Radius.circular(15.0) : Radius.zero,
                      topRight: isCurrentUser ? Radius.zero : Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 28.0, 14.0),
                    child: Column(
                      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isCurrentUser)
                        Text(
                          
                          senderName,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: 4.0), // Added space between senderName and message
                        Text(
                          message,
                          style: TextStyle(
                            color: fontColor,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                  const Positioned(
                    bottom: 10.0,
                    right: 10.0,
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
