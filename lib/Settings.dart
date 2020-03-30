import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reef_ai/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {

  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();

}

class _SettingsState extends State<Settings> {

  bool _settingsChanged;

  @override
  void initState() {
    super.initState();
    _settingsChanged = false;
  }

  void _updateStartUpDetection(bool value) {
    setState(() {
      startUpDetection = value;
      _settingsChanged = true;
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('startUpDetection', startUpDetection);
    setState(() {
      _settingsChanged = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: <Widget>[
          IconButton(
            color: _settingsChanged ? Colors.white : Colors.grey,
            icon: Icon(Icons.check),
            onPressed: () => _settingsChanged ? _saveSettings() : {},
          ),
        ],
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
                          "Enable detection on start: ",
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
                          groupValue: startUpDetection ?? false,
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
                          groupValue: startUpDetection ?? true,
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