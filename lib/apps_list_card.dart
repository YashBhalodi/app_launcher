import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

//TODO repair this file, infinite wait loading the list

class AppsCardList extends StatelessWidget {
  bool includeAppIcons = true;

  bool includeSystemApps = true;
  bool onlyAppsWithLaunchIntent = true;
  double cardHeight = 80.0;
  double bottomMargin = 10.0;
  TextStyle textStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500);

  AppsCardList(
      {Key key,
      this.includeAppIcons,
      this.includeSystemApps,
      this.onlyAppsWithLaunchIntent,
      this.cardHeight,
      this.bottomMargin,
      this.textStyle})
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
          includeAppIcons: includeAppIcons,
          onlyAppsWithLaunchIntent: onlyAppsWithLaunchIntent,
          includeSystemApps: includeSystemApps),
      builder: (context, appSnap) {
        switch (appSnap.data) {
          case null:
            return Center(child: new CircularProgressIndicator());
            break;
          default:
            {
              List<Application> appList = appSnap.data;
              appList.sort((a, b) {
                return a.appName
                    .toLowerCase()
                    .compareTo(b.appName.toLowerCase());
              });
              return ListView.builder(
                  itemCount: appList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: this.cardHeight,
                      margin: EdgeInsets.only(bottom: this.bottomMargin),
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
                              child: appList[index] is ApplicationWithIcon
                                  ? FlutterLogo(
                                      size: cardHeight - 30.0,
                                    ) //TODO place application icon here
                                  : FlutterLogo()),
                          //app name
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(appList[index].appName,
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
                              Vibrate.feedback(FeedbackType.success);
                              _showAcknowledgement(appList[index].appName);
                              DeviceApps.openApp(appList[index].packageName);
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
                  });
            }
        }
      },
    );
  }
}
