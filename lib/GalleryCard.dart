import 'package:flutter/material.dart';
import 'package:animated_card/animated_card.dart';
import 'dart:io';

class GalleryCard extends StatelessWidget {

  final FileSystemEntity imageFile;
  final String info;

  const GalleryCard({Key key, this.imageFile, this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      direction: AnimatedCardDirection.left,
      initDelay: Duration(milliseconds: 0),
      duration: Duration(milliseconds: 250),
      child: Row(
        children: <Widget> [
          Expanded(
            flex: 2,
            child: Image.file(File(imageFile.path)),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(info)
            ),
          )
        ],
      ),
    );
  }


}