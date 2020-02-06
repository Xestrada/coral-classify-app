import 'package:flutter/material.dart';
import 'dart:io';

class GalleryCard extends StatelessWidget {

  final String imagePath;
  final String info;

  const GalleryCard({Key key, this.imagePath, this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget> [
          Expanded(
            flex: 2,
            child: Image.file(File(imagePath)),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(info),
            ),
          )

        ],
      ),
    );
  }


}