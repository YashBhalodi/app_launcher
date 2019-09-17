import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  @override
  Widget build(BuildContext context) {
    Future getList() async {
      List<Application> appList = [];
      appList = await DeviceApps.getInstalledApplications(includeSystemApps: true,onlyAppsWithLaunchIntent: true);
      return appList;       //TODO return alphabetically sorted list
    }

    Widget listAppWidget = FutureBuilder(
      builder: (context, appSnap) {
        if (appSnap.connectionState == ConnectionState.none &&
            appSnap.hasData == null) {
          return Container(child: Text("Some error has occured!"));
        }
        return ListView.builder(
//          itemCount: appSnap.data.length, //TODO determine whether length here is causing the problem and proceed with importing icons
          itemBuilder: (context, index) {
            Application appEntity = appSnap.data[index];
            return new AppCard(app: appEntity);
          },
        );
      },
      future: getList(),
    );

    Future<void> _exitPrompt() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap buttons!
        builder: (BuildContext context) {
          return AlertDialog(
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

    return Scaffold(
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
      body: listAppWidget, //TODO progress indicator while future is building
    );
  }
}

class AppCard extends StatelessWidget {
  AppCard({Key key, this.app}) : super(key: key);
  final Application app;

  Widget _showAcknowledgement(String a) {
    return SimpleDialog(
      children: <Widget>[
        new Text("Launching $a..."),
        new CircularProgressIndicator(),
      ],
      title: Text(
        "Roger that!",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          //icon
          SizedBox(
              height: double.maxFinite,
              child: FlutterLogo(
                size: 50.0,
              )),   //TODO place app icon here
          //app name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(app.appName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
          //launch button
          MaterialButton(
            height: double.maxFinite,
            elevation: 5.0,
            animationDuration: Duration(milliseconds: 500),
            highlightColor: Colors.cyan,
            splashColor: Colors.white,
            onPressed: () {
              //TODO repair acknowledgement prompt
              _showAcknowledgement(app.appName);
              DeviceApps.openApp(app.packageName);
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            color: Colors.blue,
            child: Center(
                child: Icon(
              Icons.launch,
              color: Colors.white,
              size: 40.0,
            )),
          ),
        ],
      ),
    );
  }
}
