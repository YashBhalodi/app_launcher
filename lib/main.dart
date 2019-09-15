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
      List<Application> appList = await DeviceApps.getInstalledApplications();
      return appList;
    }

    Widget listAppWidget = FutureBuilder(
      builder: (context, appSnap) {
        if (appSnap.connectionState == ConnectionState.none &&
            appSnap.hasData == null) {
          return Container(child: Text("Some error has occured!"));
        }
        return ListView.builder(
          itemCount: appSnap.data.length,
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
        barrierDismissible: false, // user must tap button!
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
                onPressed: () {Navigator.of(context).pop();},
                color: Colors.blueAccent,
                textColor: Colors.white,
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(color: Colors.red[300],
              onPressed: _exitPrompt, /*() {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },*/
              child: Icon(Icons.close,color: Colors.white,size: 30.0,),
            ),
          ],
          title: Text(widget.title),
        ),
        body: listAppWidget);
  }
}

class AppCard extends StatelessWidget {
  AppCard({Key key, this.app}) : super(key: key);
  final Application app;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
          border: Border.all(width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          //icon
          Container(
            width: 50.0,
            height: 50.0,
            child: FlutterLogo(), //TODO
          ),
          //column with name, package name
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(app.appName,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(app.packageName,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                ),
              ],
            ),
          ),
          //launch button
          Container(
            width: 50.0,
            height: 50.0,
            child: FlatButton(
                onPressed: () {
                  DeviceApps.openApp(app.packageName);
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Icon(Icons.launch,color: Colors.blueAccent,size: 25.0,),),
          ),
        ],
      ),
    );
  }
}
