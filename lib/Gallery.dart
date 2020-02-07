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

  @override
  void initState() {
    super.initState();
    _getDownloadDir();
  }

  void _getDownloadDir() async {
    _downloadDir = DownloadsPathProvider.downloadsDirectory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
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