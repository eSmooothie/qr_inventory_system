import 'package:flutter/material.dart';
import 'activities/daily.dart';
import 'activities/borrow.dart';
import 'activities/monthly.dart';
import 'activities/maintenance.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: true,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _sizeBoxWidth = 250.0;
  EdgeInsets _btnMarginEdgeInsets = EdgeInsets.all(20.0);
  ButtonStyle _buttonStyle = ButtonStyle(
      side:
          MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.blue)),
      padding: MaterialStateProperty.all(EdgeInsets.all(20.0)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Inventory System"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: _btnMarginEdgeInsets,
              child: SizedBox(
                  width: _sizeBoxWidth,
                  child: TextButton(
                      style: _buttonStyle,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Daily()));
                      },
                      child: Text("Daily"))),
            ),
            Container(
              margin: _btnMarginEdgeInsets,
              child: SizedBox(
                width: _sizeBoxWidth,
                child: TextButton(
                    style: _buttonStyle,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Monthly()));
                    },
                    child: Text("Monthly")),
              ),
            ),
            Container(
              margin: _btnMarginEdgeInsets,
              child: SizedBox(
                width: _sizeBoxWidth,
                child: TextButton(
                    style: _buttonStyle,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Maintenance()));
                    },
                    child: Text("Maintenance")),
              ),
            ),
            Container(
              margin: _btnMarginEdgeInsets,
              child: SizedBox(
                width: _sizeBoxWidth,
                child: TextButton(
                    style: _buttonStyle,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Borrow()));
                    },
                    child: Text("Borrow")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
