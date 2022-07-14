import 'dart:async';
// import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DropDatabase {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(join(await getDatabasesPath(), "pos.db"), version: 1,
          onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE category(id INTEGER PRIMARY KEY autoincrement, name TEXT, include_in_drawer BIT)",
        );

        await db.execute(
          "CREATE TABLE variant(id INTEGER PRIMARY KEY autoincrement, name TEXT)",
        );

        await db.execute(
          "CREATE TABLE variantOption(id INTEGER PRIMARY KEY autoincrement, option_name TEXT, variant_id INTEGER, FOREIGN KEY (variant_id) REFERENCES variant(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE product(id INTEGER PRIMARY KEY autoincrement, name TEXT, alias TEXT, purchase DOUBLE, price DOUBLE, picture TEXT, barcode TEXT, enable_product BIT, quantity INTEGER, weight DOUBLE, has_variant BIT)",
        );

        await db.execute(
          "CREATE TABLE categoryProduct(id INTEGER PRIMARY KEY autoincrement, category_id INTEGER, product_id INTEGER, FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE variantProduct(id INTEGER PRIMARY KEY autoincrement, variant_id INTEGER, product_id INTEGER, FOREIGN KEY (variant_id) REFERENCES variant(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE productVariantOption(id INTEGER PRIMARY KEY autoincrement, product_id INTEGER, variant_id INTEGER, option_id INTEGER, price DOUBLE, FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (variant_id) REFERENCES variant(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (option_id) REFERENCES variantOption(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE shoppingCart(id INTEGER PRIMARY KEY autoincrement, subtotal DOUBLE, cart_purchase_price_total DOUBLE, total_discount DOUBLE, cart_item_quantity INTEGER, timestamp TEXT, checked_out BIT, on_hold BIT, return_order BIT)",
        );

        await db.execute(
          "CREATE TABLE shoppingCartProduct(id INTEGER PRIMARY KEY autoincrement, product_quantity INTEGER, product_subtotal DOUBLE, product_discount DOUBLE, product_purchase_price_total DOUBLE, has_variant_option BIT, product_id INTEGER, shopping_cart_id INTEGER, FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (shopping_cart_id) REFERENCES shoppingCart(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE session(id INTEGER PRIMARY KEY autoincrement, opening_balance DOUBLE, opening_time TEXT, closing_time TEXT, session_comment TEXT, close_status BIT, drawer_status BIT)",
        );

        await db.execute(
          "CREATE TABLE posOrder(id INTEGER PRIMARY KEY autoincrement, order_subtotal DOUBLE, order_purchase_price_total DOUBLE, order_discount DOUBLE, cash_collected DOUBLE, change_due DOUBLE, order_item_no INTEGER, timestamp TEXT, qr_code_string TEXT, payment_completion_status BIT, cart_id INTEGER, session_id INTEGER, FOREIGN KEY (cart_id) REFERENCES shoppingCart(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE expense(id INTEGER PRIMARY KEY autoincrement, expense_type TEXT, reason TEXT, amount DOUBLE, timestamp TEXT, session_id INTEGER, FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE selectedProductVariant(id INTEGER PRIMARY KEY autoincrement, option_name TEXT, price DOUBLE, product_variant_option_id INTEGER, option_id INTEGER, variant_id INTEGER, product_id INTEGER, shopping_cart_id INTEGER, shopping_cart_product_id INTEGER, FOREIGN KEY (product_variant_option_id) REFERENCES productVariantOption(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (option_id) REFERENCES variantOPtion(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (variant_id) REFERENCES variant(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (shopping_cart_id) REFERENCES shoppingCart(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (shopping_cart_product_id) REFERENCES shoppingCartProduct(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE barcode(id INTEGER PRIMARY KEY autoincrement, name TEXT, barcode_text TEXT, product_id INTEGER, FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE qrCode(id INTEGER PRIMARY KEY autoincrement, name TEXT, qr_data TEXT)",
        );

        await db.execute(
          "CREATE TABLE invoice(id INTEGER PRIMARY KEY autoincrement, invoice_subtotal DOUBLE, invoice_discount DOUBLE, invoice_paid_amount DOUBLE, invoice_payable_amount DOUBLE, invoice_item_no INTEGER, customer_name TEXT, customer_address TEXT, customer_phone TEXT, customer_email TEXT, qr_code_string TEXT, invoice_number TEXT, invoice_issue_date TEXT, invoice_due_date TEXT, invoice_paid_status BIT, cart_id INTEGER, session_id INTEGER, order_id INTEGER, FOREIGN KEY (cart_id) REFERENCES shoppingCart(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (session_id) REFERENCES session(id) ON DELETE CASCADE ON UPDATE CASCADE, FOREIGN KEY (order_id) REFERENCES posOrder(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE notification(id INTEGER PRIMARY KEY autoincrement, subject TEXT, timestamp TEXT, detail_id TEXT, note_type TEXT, seen_status BIT)",
        );

        await db.execute(
          "CREATE TABLE user(id INTEGER PRIMARY KEY autoincrement, name TEXT, phone TEXT, email TEXT, business TEXT, address TEXT, password TEXT, logo TEXT DEFAULT 'no_logo', remember_me BIT DEFAULT 1, access_code TEXT, start_contract_at TEXT, end_contract_at TEXT)",
        );

        await db.execute(
          "CREATE TABLE appLanguage(id INTEGER PRIMARY KEY autoincrement, language_code TEXT, country_code TEXT, active BIT)",
        );

        await db.execute(
          "CREATE TABLE productLog(id INTEGER PRIMARY KEY autoincrement, name TEXT, purchase DOUBLE, price DOUBLE, barcode TEXT, enable_product BIT, quantity INTEGER, weight DOUBLE, has_variant BIT, all_log_id INTEGER, FOREIGN KEY (all_log_id) REFERENCES allLogs(id) ON DELETE CASCADE ON UPDATE CASCADE)",
        );

        await db.execute(
          "CREATE TABLE allLogs(id INTEGER PRIMARY KEY autoincrement, operation TEXT, detail TEXT, model_id INTEGER, model TEXT, timestamp TEXT)",
        );

        await db.execute(
          "CREATE TABLE logActivation(id INTEGER PRIMARY KEY autoincrement, log_activate BIT, backup_activation BIT)",
        );

        await db.execute(
          "CREATE TABLE backupHistory(id INTEGER PRIMARY KEY autoincrement, model TEXT, model_id INTEGER, operation TEXT)",
        );

        await db.execute(
          "CREATE TABLE backupActivation(id INTEGER PRIMARY KEY autoincrement, log_activate BIT)",
        );

        print("database created");
      }, onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      });
    }
  }

  //

  Future<void> deleteCategory() async {
    await openDb();
    await _database.delete('category');
    // await _database.rawQuery('DELETE FROM category WHERE id=$id'); //alternative
  }

  //

  Future<void> deleteVariant() async {
    await openDb();
    await _database.delete('variant');
  }

  //

  Future<void> deleteVariantOption() async {
    await openDb();
    await _database.delete('variantOption');
  }

  //

  Future<void> deleteProduct() async {
    await openDb();
    await _database.delete('product');
  }

  //

  Future<void> deleteProdcutVariantOption() async {
    await openDb();
    await _database.delete('productVariantOption');
  }

  //

  Future<void> deleteCategoryProduct() async {
    await openDb();
    await _database.delete('categoryProduct');
  }

  //

  Future<void> deleteVariantProduct() async {
    await openDb();
    await _database.delete('variantProduct');
  }

  //

  Future<void> deleteShoppingCart() async {
    await openDb();
    await _database.delete('shoppingCart');
  }

  //

  Future<void> deleteShoppingCartProduct() async {
    await openDb();
    await _database.delete('shoppingCartProduct');
  }

  //

  // Future<void> deleteShoppingCartProductVariant() async {
  //   await openDb();
  //   await _database.delete('shoppingCartProductVariant');
  // }

  //

  Future<void> deleteSession() async {
    await openDb();
    await _database.delete('session');
  }

  //

  Future<void> deleteOrder() async {
    await openDb();
    await _database.delete('posOrder');
  }

  //

  Future<void> deleteExpense() async {
    await openDb();
    await _database.delete('expense');
  }

  //

  Future<void> deleteSelectedProductVariant() async {
    await openDb();
    await _database.delete('selectedProductVariant');
  }

  //

  Future<void> deleteBarcode() async {
    await openDb();
    await _database.delete('barcode');
  }

  //

  Future<void> deleteInvoice() async {
    await openDb();
    await _database.delete('invoice');
  }

  //

  Future<void> deleteNotification() async {
    await openDb();
    await _database.delete('notification');
  }

  //

  Future<void> deleteAllLogs() async {
    await openDb();
    await _database.delete('allLogs');
  }

  //

  Future<void> deleteProductLog() async {
    await openDb();
    await _database.delete('productLog');
  }
}
