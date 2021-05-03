import 'package:flutter/material.dart';
import 'dart:io';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_inventory_system/alert_dialog.dart';

import 'package:qr_inventory_system/inventory/monthly_inventory.dart';
import 'package:qr_inventory_system/other/technicians.dart';

class Monthly extends StatefulWidget {
  @override
  _MonthlyState createState() => _MonthlyState();
}

class _MonthlyState extends State<Monthly> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String _isWorking = 'Yes';

  // list of technicans
  List<Technician> _technicians = Technicians().staff();
  Technician _scanBy;

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
        title: Text("Monthly Inventory"),
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
      child: Column(
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
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(border: _borderDecor),
            child: Flexible(
                flex: 4,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Is working?"),
                        SizedBox(
                          width: 50.0,
                        ),
                        DropdownButton(
                          value: _isWorking,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 20.0),
                          underline: Container(
                            height: 2,
                            color: Colors.blue,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              _isWorking = newValue;
                            });
                          },
                          items: <String>['Yes', 'No']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Scan By: "),
                        SizedBox(
                          width: 50.0,
                        ),
                        DropdownButton(
                          value: _scanBy,
                          hint: Text("Select your name."),
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.blue),
                          underline: Container(
                            height: 2,
                            color: Colors.blue,
                          ),
                          onChanged: (Technician newValue) {
                            setState(() {
                              _scanBy = newValue;
                            });
                          },
                          items: _technicians.map((Technician tech) {
                            return DropdownMenuItem<Technician>(
                              value: tech,
                              child: Text(tech.name),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 50.0),
                      width: 200,
                      child: TextButton(
                        style: _buttonStyle,
                        onPressed: () {
                          if (_scanBy != null) {
                            MonthlyItem _newEntry = MonthlyItem(
                              item: result.code,
                              is_working: _isWorking,
                              scan_by: _scanBy.name,
                              date: DateTime.now().toString(),
                            );
                            print(_newEntry.toString());

                            MonthlyInventory _monthlyInventory =
                                MonthlyInventory();
                            _monthlyInventory.insert(_newEntry);

                            Alert_dialog(
                              context: context,
                              title: "Success",
                              msg: "Added: ${_newEntry.toString()}",
                            ).show();
                            reset();
                          } else {
                            // display error
                            print("Scan by cannot be empty.");
                            Alert_dialog(
                              context: context,
                              title: "Error",
                              msg: "scan_by cannot be null.",
                            ).show();
                          }
                        },
                        child: Text("Save"),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void reset() {
    setState(() {
      // reset
      result = null;
      _isWorking = 'Yes';
      _scanBy = null;
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
