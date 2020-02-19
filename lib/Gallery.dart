import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import './GalleryCard.dart';
import './ClassifyPage.dart';
import './DetectedData.dart';

class Gallery extends StatefulWidget {

  const Gallery({Key key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();

}

class _GalleryState extends State<Gallery> {

  Future<Directory> _programDir;
  bool _gridStyle = false;
  List<Future<DetectedData>> detectedData;

  @override
  void initState() {
    super.initState();
    detectedData = new List();
    _getProgramDir();
  }

  /// Get Program files Directory
  void _getProgramDir() async {
    _programDir = getApplicationDocumentsDirectory();
  }

  /// Switch to ListView/GridView
  void _swapGalleryStyle() {
    setState(() {
      _gridStyle = !_gridStyle;
    });
  }

  /// Go to the Classify page
  void _goToClassifyPage(String file, DetectedData data) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClassifyPage(path: file, data: data)
        )
    );
  }

  Future<DetectedData> _getJSONDataOf(String path) async {
    File jsonFile = File("${path.substring(0, path.length - 4)}.json");
    String s = await jsonFile.readAsString();
    return DetectedData.fromJson(json.decode(s));
  }

  /// Build the Grid View
  Widget _buildGrid(Iterable<FileSystemEntity> images) {
    //TODO - Fix Bad image layout
    return GridView.count(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: List.generate(images.length, (index) {
          return FutureBuilder(
            future: detectedData.elementAt(index),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 20,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: FileImage(
                          File(images.elementAt(index).path),
                          scale: 0.5,
                        ),
                      ),
                    ),
                  ),
                  onTap: () =>
                      _goToClassifyPage(
                          images.elementAt(index).path,
                          snapshot.data
                      )
                );
              } else {
                return Center(
                  child: CircularProgressIndicator()
                );
              }
            }
          );
        })
    );
  }

  /// Build the List View
  Widget _buildList(Iterable<FileSystemEntity> images) {
    return ListView.separated(
      primary: true,
      itemBuilder: (context, index) => FutureBuilder (
        future: detectedData.elementAt(index),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {
              return GestureDetector(
                  onTap: () =>
                      _goToClassifyPage(
                        images.elementAt(index).path,
                        snapshot.data
                      ),
                  child: GalleryCard(
                      imageFile: images.elementAt(index),
                      info: snapshot.data?.detectedClass ?? "No Coral Detected",
                  )
              );
            } else {
              return Center();
            }
          }
      ),
      separatorBuilder: (context, index) => Divider(
        color: Colors.white,
      ),
      itemCount: images.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
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
        color: Colors.white,
        child: FutureBuilder<Directory>(
          future: _programDir,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {

              // Get all image files in Downloads dir
              Iterable<FileSystemEntity> images = snapshot.data
                  .listSync(recursive: false, followLinks: false).where((FileSystemEntity e) {
                    return e.path.contains(".jpg") || e.path.contains(".png");
              });

              // Get and read all JSON files
              images.forEach( (FileSystemEntity image) {
                detectedData.add(_getJSONDataOf(image.path));
              });

              // Show either GridView or ListView
              return !_gridStyle ? _buildList(images) : _buildGrid(images);


            } else {
              return Center(child: CircularProgressIndicator(),);
            }

          }
        ),
      ),
    );
  }
}