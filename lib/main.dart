import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(AppEntry(
      navigatorKey: GlobalKey<NavigatorState>(),
      mainAppScaffoldKey: GlobalKey<ScaffoldState>(),
    ));
  });
}

class AppEntry extends StatefulWidget {
  final navigatorKey, mainAppScaffoldKey;

  const AppEntry(
      {Key key, @required this.navigatorKey, @required this.mainAppScaffoldKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AppEntryState();
  }
}

class AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.orange,
    ));

    return MaterialApp(
        navigatorKey: widget.navigatorKey,
        title: "Weqasa",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.blueAccent,
            primaryIconTheme: const IconThemeData(color: Colors.amber),
            primaryTextTheme:
                const TextTheme(headline6: TextStyle(color: Color(0XFF7C73E6))),
            textTheme: const TextTheme(
                headline6: TextStyle(color: Color(0XFF7C73E6)))),
        home: const HomePageView());
  }
}
