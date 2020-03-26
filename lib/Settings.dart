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
      body: ListView.builder(
          itemBuilder: (context, position) {
            return Card(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Text("Enable Detection on Start-up: "),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Radio(
                          value: false,
                          groupValue: _startUpDetection,
                          onChanged: (value) => _updateStartUpDetection(value),
                        ),
                        Text("Disabled"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Radio(
                          value: true,
                          groupValue: _startUpDetection,
                          onChanged: (value) => _updateStartUpDetection(value),
                        ),
                        Text("Enabled"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        itemCount: 1,
      ),
    );
  }

}