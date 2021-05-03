import 'package:flutter/material.dart';
import 'dart:io';

import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:qr_inventory_system/inventory/maintenance.dart';
import 'package:qr_inventory_system/other/technicians.dart';

import '../alert_dialog.dart';
import 'package:date_field/date_field.dart';

class Maintenance extends StatefulWidget {
  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  // variables
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String _isWorking = 'Yes';
  DateTime _startingDate = DateTime(2020);
  DateTime _endDate = DateTime(9999);
  DateTime _repaireDate;

  TextEditingController _diagController = TextEditingController();
  TextEditingController _repairStatController = TextEditingController();

  // list of technicans
  List<Technician> _technicians = Technicians().staff();
  Technician _technician;

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
        title: Text("Maintenance"),
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
          Container(
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
            ),
          ),
          Container(
              child: Container(
            margin: const EdgeInsets.only(top: 15.0),
            width: 200,
            child: TextButton(
              style: _buttonStyle,
              onPressed: () {
                reset();
              },
              child: Text("Rescan"),
            ),
          )),
          Container(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: TextField(
                    controller: _diagController,
                    decoration: InputDecoration(labelText: "Diagnostic"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: TextField(
                    controller: _repairStatController,
                    decoration: InputDecoration(labelText: "Repair status"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: DateTimeField(
                    decoration: InputDecoration(labelText: "Date repaired"),
                    mode: DateTimeFieldPickerMode.date,
                    selectedDate: _repaireDate,
                    onDateSelected: (DateTime value) {
                      setState(() {
                        _repaireDate = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30.0),
                  child: DropdownButton(
                    isExpanded: true,
                    value: _technician,
                    hint: Text("Select the technician"),
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
                        _technician = newValue;
                      });
                    },
                    items: _technicians.map((Technician tech) {
                      return DropdownMenuItem<Technician>(
                        value: tech,
                        child: Text(tech.name),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50.0),
                  width: 200,
                  child: TextButton(
                    style: _buttonStyle,
                    onPressed: () {
                      if (_diagController.text != "" &&
                          _repairStatController.text != "") {
                        String technician =
                            (_technician != null) ? _technician.name : "null";

                        MaintenanceItem _newEntry = MaintenanceItem(
                          item: result.code,
                          diagnostic: _diagController.text,
                          repair_status: _repairStatController.text,
                          date_repaired: _repaireDate.toString(),
                          technician: technician,
                        );

                        MaintenanceInventory _maintenanceInv =
                            MaintenanceInventory();
                        _maintenanceInv.insert(_newEntry);

                        Alert_dialog(
                          context: context,
                          title: "Success",
                          msg: "Added: ${_newEntry.toString()}",
                        ).show();
                        reset();
                      } else {
                        // display error
                        Alert_dialog(
                          context: context,
                          title: "Error",
                          msg: "Diagnostic and Repair status cannot be null.",
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
    setState(() {
      // reset
      result = null;
      _diagController.text = "";
      _repairStatController.text = "";
      _repaireDate = null;
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
