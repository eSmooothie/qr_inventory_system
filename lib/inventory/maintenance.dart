import 'package:gsheets/gsheets.dart';
import 'package:qr_inventory_system/inventory/myCredentials.dart';

class MaintenanceItem {
  final String item; // qr_code = item_name + owner + loc + date_acq
  final String diagnostic;
  final String repair_status;
  final String date_repaired;
  final String technician;

  // constructor
  const MaintenanceItem({
    this.item,
    this.diagnostic,
    this.repair_status,
    this.date_repaired,
    this.technician,
  });

  @override
  String toString() =>
      'Data {item: $item, diagnostic: $diagnostic, repair status: $repair_status, date repaired: $date_repaired, technician: $technician}';

  factory MaintenanceItem.fromGsheets(Map<String, dynamic> json) {
    return MaintenanceItem(
      item: json['item'],
      diagnostic: json['diagnostic'],
      repair_status: json['repair_status'],
      date_repaired: json['date_repaired'],
      technician: json['technician'],
    );
  }

  Map<String, dynamic> toGsheets() {
    return {
      'item': item,
      'diagnostic': diagnostic,
      'repair_status': repair_status,
      'date_repaired': date_repaired,
      'technician': technician,
    };
  }
}

class MaintenanceInventory {
  final MyCredentials myCredentials = MyCredentials();
  GSheets _gsheets;
  Spreadsheet _spreadsheet;
  Worksheet _inventorySheet;

  MaintenanceInventory() {
    _gsheets = GSheets(myCredentials.getCredentials());
  }

  Future<void> init() async {
    _spreadsheet ??=
        await _gsheets.spreadsheet(myCredentials.getSpreadSheetId());
    _inventorySheet ??= await _spreadsheet.worksheetByTitle('Maintenance');
  }

  // retrieve all data
  Future<List<MaintenanceItem>> getAll() async {
    await init();
    final products = await _inventorySheet.values.map.allRows();
    return products.map((json) => MaintenanceItem.fromGsheets(json)).toList();
  }

  // get data by id
  Future<MaintenanceItem> getById(String id) async {
    await init();
    final map = await _inventorySheet.values.map.rowByKey(
      id,
      fromColumn: 1,
    );
    return map == null ? null : MaintenanceItem.fromGsheets(map);
  }

  // insert new data
  Future<bool> insert(MaintenanceItem data) async {
    await init();
    return _inventorySheet.values.map.appendRow(
      data.toGsheets(),
      appendMissing: true,
    );
  }

  // delete data by id
  Future<bool> deleteById(String item) async {
    await init();
    final index = await _inventorySheet.values.rowIndexOf(item);
    if (index > 0) {
      return _inventorySheet.deleteRow(index);
    }
    return false;
  }

  Future<bool> delete(MaintenanceItem data) => deleteById(data.item);
}
