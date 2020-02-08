import 'package:flutter/material.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'dart:io';
import './GalleryCard.dart';
import './ClassifyPage.dart';

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

  /// Get the Download Directory
  void _getDownloadDir() async {
    _downloadDir = DownloadsPathProvider.downloadsDirectory;
  }

  /// Switch to ListView/GridView
  void _swapGalleryStyle() {
    setState(() {
      _gridStyle = !_gridStyle;
    });
  }

  void _goToClassifyPage(String file) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClassifyPage(path: file)
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
        actions: <Widget>[
          IconButton(
            icon: Icon(!_gridStyle ? Icons.grid_on : Icons.list),
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

                  // Get all image files in Downloads dir
                  Iterable<FileSystemEntity> images = snapshot.data
                      .listSync(recursive: false, followLinks: false).where((FileSystemEntity e) {
                        return e.path.contains(".jpg") || e.path.contains(".png");
                  });

                  // Show either GridView or ListView
                  return !_gridStyle ? ListView.separated(
                    itemBuilder: (context, index) => GestureDetector(
                        onTap: () => _goToClassifyPage(images.elementAt(index).path),
                        child: GalleryCard(imageFile: images.elementAt(index), info: '$index')
                      ),
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: images.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                  )
                      :
                  GridView.count(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    children: List.generate(images.length, (index) {
                      return GestureDetector(
                        child: Center(
                          child: Image.file(File(images.elementAt(index).path))
                        ),
                        onTap: () => _goToClassifyPage(images.elementAt(index).path),
                      );
                    })
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