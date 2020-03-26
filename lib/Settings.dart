import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {

  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();

}

class _SettingsState extends State<Settings> {

  bool _startUpDetection;

  @override
  void initState() {
    super.initState();
    _startUpDetection = true;
  }

  void _updateStartUpDetection(bool value) {
    setState(() {
      _startUpDetection = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Column(
        children: <Widget> [
          Container(
            height: 80,
            child: Card(
              margin: EdgeInsets.all(0),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Enable Detection on Start-up: ",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Radio(
                          activeColor: Colors.red,
                          value: false,
                          groupValue: _startUpDetection,
                          onChanged: (value) => _updateStartUpDetection(value),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Radio(
                          value: true,
                          groupValue: _startUpDetection,
                          onChanged: (value) => _updateStartUpDetection(value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.grey,
          )
        ]
      ),
    );
  }

}