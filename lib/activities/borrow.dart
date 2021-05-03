import 'package:flutter/material.dart';
import 'dart:io';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../alert_dialog.dart';

import 'package:qr_inventory_system/inventory/borrow.dart';

class Borrow extends StatefulWidget {
  @override
  _BorrowState createState() => _BorrowState();
}

class _BorrowState extends State<Borrow> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  TextEditingController _whoController = TextEditingController();
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();

  ButtonStyle _buttonStyle = ButtonStyle(
      side:
          MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.blue)),
      padding: MaterialStateProperty.all(EdgeInsets.all(20.0)));

  Border _borderDecor = Border(
    bottom: const BorderSide(color: Colors.blue),
    top: const BorderSide(color: Colors.blue),
    left: const BorderSide(color: Colors.blue),
    right: const BorderSide(color: Colors.blue),
  );

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Borrow"),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            // back
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result != null)
            Flexible(flex: 1, child: _doneScan(context))
          else
            Flexible(flex: 1, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _doneScan(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          Flexible(
              flex: 1,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: 'Item:\n',
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${result.code}',
                        style: TextStyle(height: 2.0),
                      )
                    ]),
              )),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Flexible(
                flex: 1,
                child: Container(
                  width: 200,
                  child: TextButton(
                    style: _buttonStyle,
                    onPressed: () {
                      reset();
                    },
                    child: Text("Rescan"),
                  ),
                )),
          ),
          Container(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: TextField(
                    controller: _whoController,
                    decoration: InputDecoration(labelText: "Who"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: TextField(
                    controller: _fromController,
                    decoration: InputDecoration(labelText: "Current location"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: TextField(
                    controller: _toController,
                    decoration: InputDecoration(labelText: "Transfer location"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50.0),
                  width: 200,
                  child: TextButton(
                    style: _buttonStyle,
                    onPressed: () {
                      // do something here
                      // print(
                      //     "Data: ${_whoController.text} ${_fromController.text} ${_toController.text}");
                      // print(_whoController.text != "" &&
                      //     _fromController.text != "" &&
                      //     _toController.text != "");
                      if (_whoController.text != "" &&
                          _fromController.text != "" &&
                          _toController.text != "") {
                        BorrowItem _newEntry = BorrowItem(
                          item: result.code,
                          who: _whoController.text,
                          when: DateTime.now().toString(),
                          from: _fromController.text,
                          to: _toController.text,
                        );

                        BorrowInventory _borrowInventory = BorrowInventory();
                        _borrowInventory.insert(_newEntry);

                        Alert_dialog(
                          context: context,
                          title: "Success",
                          msg: "Added: ${_newEntry.toString()}",
                        ).show();
                        reset();
                      } else {
                        Alert_dialog(
                          context: context,
                          title: "Error",
                          msg: "Fill all the fields.",
                        ).show();
                      }
                    },
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void reset() {
    // reset the values
    setState(() {
      result = null;
      _whoController.text = "";
      _fromController.text = "";
      _toController.text = "";
      this.controller.resumeCamera();
    });
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        this.controller.pauseCamera();
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
