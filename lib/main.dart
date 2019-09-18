import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  @override
  Widget build(BuildContext context) {
    Future getList() async {
      List<Application> appList = await DeviceApps.getInstalledApplications(
          includeSystemApps: true,
          onlyAppsWithLaunchIntent: true,
          includeAppIcons: true);

      //sorting the list alphabetically
      appList.sort((a, b) {
        return a.appName.toLowerCase().compareTo(b.appName.toLowerCase());
      });
      return appList;
    }

    Widget listAppWidget = FutureBuilder(
      future: getList(),
      builder: (context, appSnap) {
        switch (appSnap.connectionState) {
          case ConnectionState.none:
            return Center(child: new Text("ConnectionState.none"));
            break;
          case ConnectionState.waiting:
            return Center(
              child: new CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
              ),
            );
            break;
          case ConnectionState.active:
            return Center(
              child: new CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green),
              ),
            );
            break;
          case ConnectionState.done:
            return ListView.builder(
                itemCount: appSnap.data.length,
                itemBuilder: (context, index) {
                  Application appEntity = appSnap.data[index];
                  return new AppCard(app: appEntity);
                });
            break;
          default:
            return Center(child: new CircularProgressIndicator());
        }
      },
    );

    Future<bool> _exitPrompt() async {
      //TODO invoke this function when user tries to exit app using back button
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
        body: listAppWidget,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  AppCard({Key key, this.app}) : super(key: key);
  final Application app;

  _showAcknowledgement(String a) {
    //toast acknowledgement until SimpleDialog is repaired.

    Fluttertoast.showToast(
        msg: "Closing the launcher\nLaunching $a",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);

    //possible bug in following code block
    //The next toast has unused text below the msg
    //TODO figure out the solution of extra space in toast
    /*Future.delayed(Duration(milliseconds: 1000),(){
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "Launching $a\n",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);});*/

    //intended SimpleDialog acknowledgement
    /*return new SimpleDialog(
      title: new Text("Roger that!"),
      children: <Widget>[
        Container(child: new Text("Launching $a"),),
        Container(child: new CircularProgressIndicator(),)
      ],
    );*/
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
              child: FlutterLogo(size: 50.0,)),
          //TODO place app's icon here
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
