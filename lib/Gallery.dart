import 'package:flutter/material.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'dart:io';
import './GalleryCard.dart';

class Gallery extends StatefulWidget {

  const Gallery({Key key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();

}

class _GalleryState extends State<Gallery> {

  Future<Directory> _downloadDir;
  bool _gridStyle = false;

  @override
  void initState() {
    super.initState();
    _getDownloadDir();
  }

  void _getDownloadDir() async {
    _downloadDir = DownloadsPathProvider.downloadsDirectory;
  }

  void _swapGalleryStyle() {
    setState(() {
      _gridStyle = !_gridStyle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
        actions: <Widget>[
          IconButton(
            icon: Icon(_gridStyle ? Icons.grid_on : Icons.list),
            onPressed: () => _swapGalleryStyle(),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            FutureBuilder<Directory>(
              future: _downloadDir,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done) {

                  Iterable<FileSystemEntity> images = snapshot.data
                      .listSync(recursive: false, followLinks: false).where((FileSystemEntity e) {
                        return e.path.contains(".jpg") || e.path.contains(".png");
                  });

                  return ListView.separated(
                    itemBuilder: (context, index)
                      => GalleryCard(imageFile: images.elementAt(index), info: '$index'),
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: images.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                  );

                } else {
                  return Center(child: CircularProgressIndicator(),);
                }

              }
            ),
          ],
        ),
      ),
    );
  }
}