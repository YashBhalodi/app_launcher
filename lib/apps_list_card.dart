import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

//TODO repair this file, infinite wait loading the list

class AppsCardList extends StatelessWidget {
  final bool includeSystemApps;
  final bool onlyAppsWithLaunchIntent;
  final double cardHeight;
  final double cardMarginBottom;
  final bool getIcons;
  final TextStyle appNameStyle;

  const AppsCardList(
      {Key key,
      this.includeSystemApps: true,
      this.onlyAppsWithLaunchIntent: true,
      this.cardHeight: 80.0,
      this.cardMarginBottom: 10.0,
      this.getIcons: true,
      this.appNameStyle: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      )})
      : super(key: key);

  void _showAcknowledgement(String a) {
    //toast acknowledgement until SimpleDialog is repaired.

    Fluttertoast.showToast(
        msg: "Closing the launcher\nLaunching $a",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);

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
    return FutureBuilder(
        future: DeviceApps.getInstalledApplications(
            includeAppIcons: true,
            includeSystemApps: includeSystemApps,
            onlyAppsWithLaunchIntent: onlyAppsWithLaunchIntent),
        builder: (context, data) {
          if (data.data == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            List<Application> apps = data.data;
            return ListView.builder(
                itemBuilder: (context, position) {
                  Application app = apps[position];
                  return Container(
                    height: this.cardHeight,
                    margin: EdgeInsets.only(bottom: this.cardMarginBottom),
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
                            width: this.cardHeight,
                            child: app is ApplicationWithIcon && getIcons
                                ? Image.memory(app.icon)
                                : FlutterLogo(size: this.cardHeight)),
                        //TODO place application icon here

                        //app name
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(app.appName, style: this.appNameStyle),
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
                            Vibrate.feedback(FeedbackType.success);
                            _showAcknowledgement(app.appName);
                            DeviceApps.openApp(app.packageName);
                            SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
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
                },
                itemCount: apps.length);
          }
        });
  }
}
