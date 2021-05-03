import 'package:gsheets/gsheets.dart';
import 'package:qr_inventory_system/inventory/myCredentials.dart';



class BorrowItem {
  final String item; // qr_code = item_name + owner + loc + date_acq
  final String who;
  final String when;
  final String from; // currenct loc
  final String to; // new loc

  // constructor
  const BorrowItem({
    this.item,
    this.who,
    this.when,
    this.from,
    this.to,
  });

  @override
  String toString() =>
      'Data {item: $item, who: $who, when: $when, from: $from, to: $to}';

  factory BorrowItem.fromGsheets(Map<String, dynamic> json) {
    return BorrowItem(
        item: json['item'],
        who: json['who'],
        when: json['when'],
        from: json['from'],
        to: json['to']);
  }

  Map<String, dynamic> toGsheets() {
    return {
      'item': item,
      'who': who,
      'when': when,
      'from': from,
      'to': to,
    };
  }
}

class BorrowInventory {
  final MyCredentials myCredentials = MyCredentials();
  GSheets _gsheets;
  Spreadsheet _spreadsheet;
  Worksheet _inventorySheet;

  BorrowInventory() {
    _gsheets = GSheets(myCredentials.getCredentials());
  }

  Future<void> init() async {
    _spreadsheet ??=
        await _gsheets.spreadsheet(myCredentials.getSpreadSheetId());
    _inventorySheet ??= await _spreadsheet.worksheetByTitle('Borrow');
    // await _inventorySheet.values.insertValue("test", column: 1, row: 1);
  }

  // retrieve all data
  Future<List<BorrowItem>> getAll() async {
    await init();
    final products = await _inventorySheet.values.map.allRows();
    return products.map((json) => BorrowItem.fromGsheets(json)).toList();
  }

  // get data by id
  Future<BorrowItem> getById(String id) async {
    await init();
    final map = await _inventorySheet.values.map.rowByKey(
      id,
      fromColumn: 1,
    );
    return map == null ? null : BorrowItem.fromGsheets(map);
  }

  // insert new data
  Future<bool> insert(BorrowItem data) async {
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

  Future<bool> delete(BorrowItem data) => deleteById(data.item);
}
