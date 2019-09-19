import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_launcher/apps_list_card.dart';

//TODO tidy up the code in separate class file after icon successfully imported
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Applications Launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<bool> _exitPrompt() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text('Oops!'),
          content: Text("You are trying to exit this app."),
          actions: <Widget>[
            RaisedButton(
              child: Text('Exit!'),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              color: Colors.red,
              textColor: Colors.white,
            ),
            RaisedButton(
              child: Text('Stay!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.blueAccent,
              textColor: Colors.white,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _exitPrompt,
      child: Scaffold(
        //TODO splash screen
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              color: Colors.red[300],
              onPressed: _exitPrompt,
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ],
          title: Text(widget.title),
        ),
        body: AppsCardList(getIcons: false,),
      ),
    );
  }
}