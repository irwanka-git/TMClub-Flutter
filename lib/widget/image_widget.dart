import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircleImageNetwork extends StatefulWidget {
  final String image;
  final double size;
  @override
  final Key key;

  const CircleImageNetwork(
    this.image,
    this.size,
    this.key,
  ) : super(key: key);
  @override
  _CircleImageNetwork createState() => _CircleImageNetwork();
}

class _CircleImageNetwork extends State<CircleImageNetwork> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.size,
      backgroundColor: CupertinoColors.systemGroupedBackground,
      foregroundColor: CupertinoColors.activeOrange,
      child: CircleAvatar(
        backgroundImage: NetworkImage(widget.image),
        radius: widget.size - (widget.size / 20),
      ),
    );
  }
}
