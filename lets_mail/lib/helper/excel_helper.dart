import 'dart:io';
import 'package:excel/excel.dart';

import 'package:lets_mail/model/email_model.dart';

class ExcelHelper {
  // Private constructor to prevent external instantiation.
  ExcelHelper._();

  // The single instance of the class.
  static final ExcelHelper _instance = ExcelHelper._();

  // Factory constructor to provide access to the singleton instance.
  factory ExcelHelper() {
    return _instance;
  }

  List<EmailModel> parseFile(File file) {
    List<EmailModel> result = [];

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        List<String> values = [];
        for (var cell in row) {
          _parseRow(cell, values);
        }

        bool skip = values.length > 2 && values[2] == 'X' ? true : false;
        if (values.isNotEmpty &&
            values[0].isNotEmpty &&
            values[0].contains("@") &&
            !skip) {
          String naam = values.length > 1 ? values[1] : "";
          result.add(EmailModel(emailAdress: values[0], signature: naam));
        }
      }
    }

    return result;
  }

  void _parseRow(Data? cell, List<String> values) {
    if (cell != null) {
      if (cell.columnIndex < 3) {
        String value = _parseCell(cell);
        values.add(value);
      }
    }
  }

  String _parseCell(Data? cell) {
    String result = '';
    if (cell != null) {
      final value = cell.value;
      switch (value) {
        case TextCellValue():
          result = '${value.value}';
        case FormulaCellValue():
          result = value.formula;
        default:
      }
    }
    return result;
  }
}
