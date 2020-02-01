import 'package:flutter/material.dart';
import 'dart:io';

class Gallery extends StatelessWidget {
  final String imagePath;

  const Gallery({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
      ),
      body: Image.file(File(imagePath)),
    );
  }
}