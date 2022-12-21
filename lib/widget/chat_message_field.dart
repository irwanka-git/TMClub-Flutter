import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessageField extends StatefulWidget {
  const ChatMessageField({Key? key}) : super(key: key);
  @override
  _ChatMessageFieldState createState() => _ChatMessageFieldState();
}

class _ChatMessageFieldState extends State<ChatMessageField> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 5,
                        color: Colors.black12)
                  ],
                ),
                child: Row(
                  children: [
                    const IconButton(
                        icon: Icon(
                          CupertinoIcons.paperclip,
                          color: CupertinoColors.activeOrange,
                        ),
                        onPressed: null),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: Get.width,
                          maxWidth: Get.width,
                          minHeight: 25.0,
                          maxHeight: Get.height,
                        ),
                        child: const Scrollbar(
                          child: TextField(
                            cursorColor: CupertinoColors.activeOrange,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(
                                color: CupertinoColors.darkBackgroundGray),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(2),
                              hintText: "Type your message",
                              hintStyle: TextStyle(
                                color: CupertinoColors.placeholderText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                  color: CupertinoColors.activeOrange, shape: BoxShape.circle),
              child: InkWell(
                child: const Icon(
                  CupertinoIcons.paperplane,
                  color: Colors.white,
                  size: 25,
                ),
                onLongPress: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
