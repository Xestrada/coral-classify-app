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
            child: Container(
              height: MediaQuery.of(context).size.height/3.5,
              foregroundDecoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: FileImage(
                    File(imageFile.path),
                    scale: 0.25,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(25.0),
              child: Text(
                  "○ $info"
              )
            ),
          )
        ],
      ),
    );
  }


}