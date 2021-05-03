import 'package:gsheets/gsheets.dart';
import 'myCredentials.dart';

class MonthlyItem {
  final String item; // qr_code = item_name + owner + loc + date_acq
  final String is_working;
  final String scan_by;
  final String date;

  // constructor
  const MonthlyItem({
    this.item,
    this.is_working,
    this.scan_by,
    this.date,
  });

  @override
  String toString() =>
      'Data {item: $item, is working: $is_working, scan by: $scan_by, date: $date}';

  factory MonthlyItem.fromGsheets(Map<String, dynamic> json) {
    return MonthlyItem(
      item: json['item'],
      is_working: json['is_working'],
      scan_by: json['scan_by'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toGsheets() {
    return {
      'item': item,
      'is_working': is_working,
      'scan_by': scan_by,
      'date': date,
    };
  }
}

class MonthlyInventory {
  final MyCredentials myCredentials = MyCredentials();
  GSheets _gsheets;
  Spreadsheet _spreadsheet;
  Worksheet _inventorySheet;

  MonthlyInventory() {
    _gsheets = GSheets(myCredentials.getCredentials());
  }

  Future<void> init() async {
    _spreadsheet ??=
        await _gsheets.spreadsheet(myCredentials.getSpreadSheetId());
    _inventorySheet ??= await _spreadsheet.worksheetByTitle('Monthly');
  }

  // retrieve all data
  Future<List<MonthlyItem>> getAll() async {
    await init();
    final products = await _inventorySheet.values.map.allRows();
    return products.map((json) => MonthlyItem.fromGsheets(json)).toList();
  }

  // get data by id
  Future<MonthlyItem> getById(String id) async {
    await init();
    final map = await _inventorySheet.values.map.rowByKey(
      id,
      fromColumn: 1,
    );
    return map == null ? null : MonthlyItem.fromGsheets(map);
  }

  // insert new data
  Future<bool> insert(MonthlyItem data) async {
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

  Future<bool> delete(MonthlyItem data) => deleteById(data.item);
}
