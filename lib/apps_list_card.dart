import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';


class AppsCardList extends StatelessWidget {
  final bool includeSystemApps;
  final bool onlyAppsWithLaunchIntent;
  final double cardHeight;
  final EdgeInsetsGeometry cardMargin;
  final bool getIcons;
  final TextStyle appNameStyle;
  final bool sortAlphabetically;

  const AppsCardList(
      {Key key,
      this.includeSystemApps: true,
      this.onlyAppsWithLaunchIntent: true,
      this.cardHeight: 80.0,
      this.cardMargin,
      this.getIcons: true,
      this.appNameStyle: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
      this.sortAlphabetically: true})
      : super(key: key);

  void _showAcknowledgement(String a) {
    Fluttertoast.showToast(
        msg: "Closing the launcher\nLaunching $a",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
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
            if (this.sortAlphabetically) {
              apps.sort((a, b) {
                return a.appName
                    .toLowerCase()
                    .compareTo(b.appName.toLowerCase());
              });
            }
            return ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, position) {
                Application app = apps[position];
                return Card(
                  child: Container(
                    height: this.cardHeight,
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
                          highlightColor: Colors.blueGrey,
                          splashColor: Colors.cyan,
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
                            Icons.navigate_next,
                            color: Colors.white,
                            size: 60.0,
                          )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        });
  }
}
