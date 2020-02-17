import 'package:flutter/material.dart';
import 'dart:io';

class GalleryCard extends StatelessWidget {

  final FileSystemEntity imageFile;
  final String info;

  const GalleryCard({Key key, this.imageFile, this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      clipBehavior: Clip.hardEdge,
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