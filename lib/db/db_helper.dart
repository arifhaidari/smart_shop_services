import 'dart:async';
// import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:pos/db/Inventory_model.dart';
import 'package:pos/db/app_language.dart';
import 'package:pos/db/bakcup_history/backup_history_model.dart';
import 'package:pos/db/barcode_model.dart';
import 'package:pos/db/expense_model.dart';
import 'package:pos/db/invoice_model.dart';
import 'package:pos/db/logs/all_logs.dart';
import 'package:pos/db/logs/log_activation.dart';
import 'package:pos/db/logs/product_log.dart';
import 'package:pos/db/monthly_date_model.dart';
import 'package:pos/db/notification_model.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/product_shopping_cart_invoicing.dart';
import 'package:pos/db/product_shopping_cart_join.dart';
import 'package:pos/db/product_variant_price_list.dart';
import 'package:pos/db/qr_code_model.dart';
import 'package:pos/db/selected_product_variant.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/db/shopping_product_model.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/pages/analytics/profit_tab.dart';
import 'package:pos/pages/analytics/revenue_tab.dart';
import 'package:pos/pages/analytics/expenses_tab.dart';
import 'package:sqflite/sqflite.dart';

// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

//My Imports
import 'package:pos/db/category_model.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/db/variant_option_model.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/db/category_product_model.dart';
import 'package:pos/db/variant_product_model.dart';
import 'package:pos/db/product_variant_option.dart';
import 'package:pos/db/shopping_cart_model.dart';

class PosDatabase {
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

////////////start other part//////////
  Future deleteDB() async {
    if (_database != null) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'pos.db');

      closeDb();
      // // Delete the database
      await deleteDatabase(path);
      //
      print("database deleted successfully");
      return true;
    }
    return false;
  }

  Future closeDb() async {
    _database.close();
  }
////////////end other part//////////

  ////////////////////// Category Part Start ////////////////
  Future<int> insertCategory(Category category) async {
    await openDb();
    return await _database.insert('category', category.toMap());
  }

  Future<int> importCategory(Category category) async {
    await openDb();
    return await _database.insert('category', category.importToMap());
  }

  Future<List<Category>> getCategoryList() async {
    await openDb();
    // deleteDB(); //delete the entire database
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM category ORDER BY id DESC');
    return maps.map((m) => Category.fromDb(m)).toList();
  }

  Future<List<Category>> getCategoryJoinList(int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT category.id AS id, category.name AS name  FROM category INNER JOIN categoryProduct ON category.id = categoryProduct.category_id WHERE categoryProduct.product_id = $productId');
    return maps.map((m) => Category.fromDb(m)).toList();
  }

  Future<List<Category>> getCategoryDrawerList() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM category WHERE include_in_drawer = 1');
    return maps.map((m) => Category.fromDb(m)).toList();
  }

  Future<int> updateCategory(Category category) async {
    await openDb();
    return await _database
        .update('category', category.toMap(), where: "id = ?", whereArgs: [category.id]);
    // return await _database
    //     .rawUpdate('UPDATE category SET name = ${category.name} WHERE id = ${category.id}');
  }

  Future<void> deleteCategory(int id) async {
    await openDb();
    await _database.delete('category', where: "id = ?", whereArgs: [id]);
    // await _database.rawQuery('DELETE FROM category WHERE id=$id'); //alternative
  }

  ////////////////////// Category Part Ends ////////////////
  ///
  ///
  //////////////////// variant Part Start ////////////////

  Future<int> insertVariant(Variant variant) async {
    await openDb();
    return await _database.insert('variant', variant.toMap());
  }

  Future<int> importVariant(Variant variant) async {
    await openDb();
    return await _database.insert('variant', variant.importToMap());
  }

  Future<List<Variant>> getVariantList() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM variant ORDER BY id DESC');
    return maps.map((m) => Variant.fromDb(m)).toList();
  }

  Future<Variant> getSingleVariant(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM variant WHERE id = $id');
    if (maps.length > 0) {
      return Variant.fromDb(maps[0]);
    }
    return null;
  }

  Future<List<Variant>> getVariantNameByProductId(int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT DISTINCT variant.id AS id, variant.name FROM variant INNER JOIN productVariantOption ON variant.id = productVariantOption.variant_id WHERE productVariantOption.product_id = $productId');
    return maps.map((m) => Variant.fromDb(m)).toList();
  }

  Future<List<Variant>> getVariantListById(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM variant WHERE id = $id');
    return maps.map((m) => Variant.fromDb(m)).toList();
  }

  Future<int> updateVariant(Variant variant) async {
    await openDb();
    return await _database
        .update('variant', variant.toMap(), where: "id = ?", whereArgs: [variant.id]);
  }

  Future<void> deleteVariant(int id) async {
    await openDb();
    await _database.delete('variant', where: "id = ?", whereArgs: [id]);
  }
  //////////////////// variant Part end ////////////////
  ///
  /////////////////////// variant_option Part Start ////////////////

  Future<int> insertVariantOption(VariantOption variantOption) async {
    await openDb();
    try {
      return await _database.insert('variantOption', variantOption.toMap());
    } catch (e) {
      return e;
    }
  }

  Future<int> importVariantOption(VariantOption variantOption) async {
    await openDb();
    try {
      return await _database.insert('variantOption', variantOption.importToMap());
    } catch (e) {
      return e;
    }
  }

  Future<int> getOptionCount(int id) async {
    List<Map<String, dynamic>> list =
        await _database.rawQuery('SELECT * FROM variantOption WHERE variant_id=$id');
    return list.length;
  }

  Future<List<VariantOption>> getVariantOptionList(int id) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.query("variantOption", where: "variant_id = ?", whereArgs: [id]);
    return maps.map((m) => VariantOption.fromDb(m)).toList();
  }

  Future<List<VariantOption>> getVariantOptionAllList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('variantOption');
    return maps.map((m) => VariantOption.fromDb(m)).toList();
  }

  // in update of variant option the id of variantOptin is not important but the foreign key of variant_id
  // so we use in where variant_id as reference
  Future<int> updateVariantOption(VariantOption variantOption) async {
    await openDb();
    return await _database.update('variantOption', variantOption.toMap(),
        where: "variant_id = ?", whereArgs: [variantOption.variant_id]);
  }

  Future<void> deleteVariantOption(int variantId) async {
    await openDb();
    await _database.delete('variantOption', where: "variant_id = ?", whereArgs: [variantId]);
  }

  //////////////////// variant_option Part end ////////////////
  ///
  ///
  ///////////////////////// Product Part Start ////////////////
  Future<int> insertProduct(Product product) async {
    await openDb();
    return await _database.insert('product', product.toMap());
  }

  Future<int> importProduct(Product product) async {
    await openDb();
    return await _database.insert('product', product.importToMap());
  }

  //
  Future<List<Product>> getProductList() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM product ORDER BY id DESC');
    return maps.map((m) => Product.fromDb(m)).toList();
  }

  Future<List<Product>> getProductListDisplay() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM product WHERE enable_product = 1');
    return maps.map((m) => Product.fromDb(m)).toList();
  }

  Future<Product> getSingleProduct(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM product WHERE id = $id');
    if (maps.length > 0) {
      return Product.fromDb(maps[0]);
    }
    return null;
  }

  Future<Product> getProductBarcode(String barcodeString) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM product WHERE barcode = "$barcodeString"');
    if (maps.length > 0) {
      return Product.fromDb(maps[0]);
    }
    return null;
  }

  Future<Product> getSingleProductByBarcode(String barcodeData) async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM product WHERE barcode = "$barcodeData" AND enable_product = 1');
    if (maps.length > 0) {
      return Product.fromDb(maps[0]);
    }
    return null;
  }

  Future<List<Product>> getProductListById(String catId) async {
    await openDb();
    if (catId == "all_categories") {
      final List<Map<String, dynamic>> maps = await _database
          .rawQuery('SELECT * FROM product WHERE enable_product = 1 ORDER BY id DESC');
      return maps.map((m) => Product.fromDb(m)).toList();
    } else {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
          // 'SELECT product.id AS id, product.name AS name, product.purchase AS purchase, product.price AS price, product.picture AS picture, product.barcode AS barcode, product.enable_product AS enable_product, product.quantity AS quantity, product.weight AS weight, product.has_variant AS has_variant FROM product INNER JOIN categoryProduct ON product.id = categoryProduct.product_id WHERE categoryProduct.category_id = $catId');
          'SELECT product.id AS id, name, purchase, price, picture, barcode, enable_product, quantity, weight, has_variant FROM product INNER JOIN categoryProduct ON product.id = categoryProduct.product_id WHERE categoryProduct.category_id = $catId AND product.enable_product = 1 ORDER BY product.id DESC');
      return maps.map((m) => Product.fromDb(m)).toList();
    }
  }

  Future<int> updateProduct(Product product) async {
    await openDb();
    return await _database
        .update('product', product.toMap(), where: "id = ?", whereArgs: [product.id]);
  }

  Future<void> deleteProduct(int id) async {
    await openDb();
    await _database.delete('product', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Product Part Ends ////////////////
  ///
  ///////////////////////// ProdcutVariantOption Part Start ////////////////
  Future<int> insertProdcutVariantOption(ProductVariantOption productVariantOption) async {
    await openDb();
    return await _database.insert('productVariantOption', productVariantOption.toMap());
  }

  Future<int> importProdcutVariantOption(ProductVariantOption productVariantOption) async {
    await openDb();
    return await _database.insert('productVariantOption', productVariantOption.importToMap());
  }

  Future<List<ProductVariantOption>> getProductVariantOptionList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('productVariantOption');
    return maps.map((m) => ProductVariantOption.fromDb(m)).toList();
  }

  Future<List<ProductVariantPriceJoinModel>> getProductVariantPriceListByJoin(
      int variantId, int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT productVariantOption.id, productVariantOption.price, productVariantOption.option_id, productVariantOption.variant_id, productVariantOption.product_id, variantOption.option_name FROM productVariantOption INNER JOIN variantOption ON productVariantOption.option_id = variantOption.id WHERE productVariantOption.variant_id = $variantId AND productVariantOption.product_id = $productId');

    return maps.map((m) => ProductVariantPriceJoinModel.fromDb(m)).toList();
  }

  Future<List<ProductVariantOption>> getProductVariantOptionListById(int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database
        .rawQuery('SELECT * FROM productVariantOption WHERE product_id = $productId');
    return maps.map((m) => ProductVariantOption.fromDb(m)).toList();
  }

  Future<List<ProductVariantOption>> getProductVariantOptionListByVariantId(
      int variantId, int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT * FROM productVariantOption WHERE product_id = $productId AND variant_id = $variantId');
    return maps.map((m) => ProductVariantOption.fromDb(m)).toList();
  }

  Future<int> updateProductVariantOption(ProductVariantOption productVariantOption) async {
    await openDb();
    return await _database.update('productVariantOption', productVariantOption.toMap(),
        where: "id = ?", whereArgs: [productVariantOption.id]);
  }

  //delete of ProductVariantOption will be done by prouct_name becasue we delete
  //all of those ProductVariantOption that related to a productNamee
  // that we can add a new one instead
  Future<void> deleteProductVariantOption(int productId) async {
    await openDb();
    var temp = await _database
        .delete('productVariantOption', where: "product_id = ?", whereArgs: [productId]);
  }

  Future<void> deleteProductVariantOptionById(int productId, int variantId) async {
    await openDb();
    await _database.rawQuery(
        'DELETE FROM productVariantOption WHERE product_id = $productId AND variant_id = $variantId');
  }

  ////////////////////// ProdcutVariantOption Part Ends ////////////////
  ///
  //////////////////////////// prodcutCategoryJoin  Part Start ////////////////
  Future<int> insertCategoryProduct(CategoryProductJoin categoryProduct) async {
    await openDb();
    return await _database.insert('categoryProduct', categoryProduct.toMap());
  }

  Future<int> importCategoryProduct(CategoryProductJoin categoryProduct) async {
    await openDb();
    return await _database.insert('categoryProduct', categoryProduct.importToMap());
  }

  Future<List<CategoryProductJoin>> getCategoryProductList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('categoryProduct');
    return maps.map((m) => CategoryProductJoin.fromDb(m)).toList();
  }

  Future<List<CategoryProductJoin>> getCategoryProductListById(int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM categoryProduct WHERE product_id = $productId');
    return maps.map((m) => CategoryProductJoin.fromDb(m)).toList();
  }

  Future<int> updateCategoryProduct(CategoryProductJoin categoryProduct) async {
    await openDb();
    return await _database.update('categoryProduct', categoryProduct.toMap(),
        where: "id = ?", whereArgs: [categoryProduct.id]);
  }

  // we delete the CategoryProductJoin by product name
  Future<void> deleteCategoryProduct(int productId) async {
    await openDb();
    await _database.delete('categoryProduct', where: "product_id = ?", whereArgs: [productId]);
  }

  ////////////////////// prodcutCategoryJoin Part Ends ////////////////
  ///
  ///
  /////////////////////////////// VariantProductJoin  Part Start ////////////////
  Future<int> insertVariantProduct(VariantProductJoin variantProduct) async {
    await openDb();
    return await _database.insert('variantProduct', variantProduct.toMap());
  }

  Future<int> importVariantProduct(VariantProductJoin variantProduct) async {
    await openDb();
    return await _database.insert('variantProduct', variantProduct.importToMap());
  }

  Future<List<VariantProductJoin>> getVariantProductList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('variantProduct');
    return maps.map((m) => VariantProductJoin.fromDb(m)).toList();
  }

  Future<List<VariantProductJoin>> getVariantProductListById(int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM variantProduct WHERE product_id = $productId');

    if (maps.length > 0) {
      return maps.map((m) => VariantProductJoin.fromDb(m)).toList();
    }
    return null;
  }

  Future<int> updateVariantProduct(VariantProductJoin variantProduct) async {
    await openDb();
    return await _database.update('variantProduct', variantProduct.toMap(),
        where: "id = ?", whereArgs: [variantProduct.id]);
  }

  Future<void> deleteVariantProduct(int productId) async {
    await openDb();
    await _database.rawQuery('DELETE FROM variantProduct WHERE product_id = $productId');
  }

  ////////////////////// VariantProductJoin Part Ends ////////////////
  ///
  ///
  /////////////////////////////// ShoppingCartModel  Part Start ////////////////
  Future<int> shoppingCartCartCreator(ShoppingCartModel shoppingCartModel) async {
    await openDb();
    return await _database.insert('shoppingCart', shoppingCartModel.toMap());
  }

  Future<int> importShoppingCartCart(ShoppingCartModel shoppingCartModel) async {
    await openDb();
    return await _database.insert('shoppingCart', shoppingCartModel.importToMap());
  }

  /// getting all the carts list
  Future<List<ShoppingCartModel>> getShoppingCartList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('shoppingCart');
    return maps.map((m) => ShoppingCartModel.fromDb(m)).toList();
  }

  Future<List<ProductShoppingCartJoin>> getProductShoppingCartListById(int shoppingCartId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT product.id AS main_product_id, product.name, product.price, product.purchase, product.picture, product.quantity, product.has_variant, shoppingCartProduct.id AS shopping_cart_product_id, shoppingCartProduct.product_quantity, shoppingCartProduct.product_subtotal, shoppingCartProduct.product_discount, shoppingCartProduct.product_id, shoppingCartProduct.has_variant_option FROM product INNER JOIN shoppingCartProduct ON product.id = shoppingCartProduct.product_id WHERE shoppingCartProduct.shopping_cart_id = $shoppingCartId ORDER BY shoppingCartProduct.id DESC');
    return maps.map((m) => ProductShoppingCartJoin.fromDb(m)).toList();
  }

  Future<int> getShoppingCartItemNo(int shoppingCartId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(product_quantity) FROM shoppingCartProduct WHERE shopping_cart_id = $shoppingCartId');
    int count = Sqflite.firstIntValue(maps);
    return count == null ? 0 : count;
  }

  Future<double> getShoppingCartGrandTotal(int shoppingCartId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(product_subtotal) AS sumValue FROM shoppingCartProduct WHERE shopping_cart_id = $shoppingCartId');
    double count = maps[0]['sumValue'];
    return count;
  }

  Future<double> getShoppingCartPurchaseTotal(int shoppingCartId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(product_purchase_price_total) AS sumValue FROM shoppingCartProduct WHERE shopping_cart_id = $shoppingCartId');
    double count = maps[0]['sumValue'];
    return count;
  }

  Future<double> getShoppingCartTotalDiscount(int shoppingCartId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(product_discount) AS sumValue FROM shoppingCartProduct WHERE shopping_cart_id = $shoppingCartId');
    double count = maps[0]['sumValue'];
    return count;
  }

  Future<ShoppingCartModel> getShoppingCart() async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM shoppingCart WHERE checked_out = 0 AND on_hold = 0');
    if (maps.length > 0) {
      return ShoppingCartModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<List<ShoppingCartModel>> getShoppingCartOnHoldlist() async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT * FROM shoppingCart WHERE checked_out = 0 AND on_hold = 1 ORDER BY id DESC');

    return maps.map((m) => ShoppingCartModel.fromDb(m)).toList();
  }

  Future<ShoppingCartModel> getShoppingCartById(int id) async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM shoppingCart WHERE checked_out = 0 AND on_hold = 0 AND id = $id');
    if (maps.length > 0) {
      return ShoppingCartModel.fromDb(maps[0]); // it will get the first result
      // return maps.map((m) => ShoppingCartModel.fromDb(m[0]));
    }
    return null;
  }

  Future<ShoppingCartModel> getShoppingCartHoldById(int id) async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM shoppingCart WHERE checked_out = 0 AND on_hold = 1 AND id = $id');
    if (maps.length > 0) {
      return ShoppingCartModel.fromDb(maps[0]); // it will get the first result
    }
    return null;
  }

  Future<ShoppingCartModel> getShoppingCartInvoicing(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM shoppingCart WHERE id = $id');
    if (maps.length > 0) {
      return ShoppingCartModel.fromDb(maps[0]); // it will get the first result
    }
    return null;
  }

  Future<int> updateShoppingCart(ShoppingCartModel shoppingCartModel) async {
    await openDb();
    return await _database.update('shoppingCart', shoppingCartModel.toMap(),
        where: "id = ?", whereArgs: [shoppingCartModel.id]);
  }

  Future<void> deleteShoppingCart(int id) async {
    await openDb();
    await _database.delete('shoppingCart', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// ShoppingCartModel Part Ends ////////////////
  ///
  /// ////////////////////// shoppingCartProduct Part Start ////////////////
  Future<int> insertShoppingCartProduct(ShoppingCartProductModel shoppingCartProductModel) async {
    await openDb();
    return await _database.insert('shoppingCartProduct', shoppingCartProductModel.toMap());
  }

  Future<int> importShoppingCartProduct(ShoppingCartProductModel shoppingCartProductModel) async {
    await openDb();
    return await _database.insert('shoppingCartProduct', shoppingCartProductModel.importToMap());
  }

  Future<List<ShoppingCartProductModel>> getShoppingCartProductList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('shoppingCartProduct');
    return maps.map((m) => ShoppingCartProductModel.fromDb(m)).toList();
  }

  Future<int> getProductQuantitySum(int productId, int shoppingCartId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(product_quantity) FROM shoppingCartProduct WHERE product_id = $productId AND shopping_cart_id = $shoppingCartId');
    int count = Sqflite.firstIntValue(maps);
    return count == null ? 0 : count;
  }

  Future<List<ShoppingCartProductModel>> getShoppingCartProductListByCartId(
      int shoppingCartId) async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM shoppingCartProduct WHERE shopping_cart_id = $shoppingCartId');
    return maps.map((m) => ShoppingCartProductModel.fromDb(m)).toList();
  }

  Future<ShoppingCartProductModel> getShoppingCartProductItem(
      int productId, int shoppingCartId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT * FROM shoppingCartProduct WHERE shopping_cart_id = $shoppingCartId AND product_id = $productId');
    if (maps.length > 0) {
      maps.forEach((f) {});
      return ShoppingCartProductModel.fromDb(maps[0]);
    }

    return null;
  }

  Future<ShoppingCartProductModel> getShoppingCartProductById(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM shoppingCartProduct WHERE id = $id');
    if (maps.length > 0) {
      return ShoppingCartProductModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateShoppingCartProduct(ShoppingCartProductModel shoppingCartProductModel) async {
    await openDb();
    return await _database.update('shoppingCartProduct', shoppingCartProductModel.toMap(),
        where: "id = ?", whereArgs: [shoppingCartProductModel.id]);
  }

  Future<void> deleteShoppingCartProductModel(int id) async {
    await openDb();
    await _database.delete('shoppingCartProduct', where: "id = ?", whereArgs: [id]);
    // await _database.rawQuery('DELETE FROM category WHERE id=$id'); //alternative
  }

  ////////////////////// shoppingCartProduct Part Ends ////////////////
  ///
  ///////////////////////// Session Part Start ////////////////
  Future<int> createSession(SessionModel sessionModel) async {
    await openDb();
    return await _database.insert('session', sessionModel.toMap());
  }

  Future<int> importSession(SessionModel sessionModel) async {
    await openDb();
    return await _database.insert('session', sessionModel.importToMap());
  }

  Future<List<SessionModel>> getSessionListByMonth(String month) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT * FROM session WHERE SUBSTR(opening_time, 1, 7) = "$month" ORDER BY id DESC');
    return maps.map((m) => SessionModel.fromDb(m)).toList();
  }

  Future<List<SessionModel>> getSessionAllList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('session');
    return maps.map((m) => SessionModel.fromDb(m)).toList();
  }

  Future<SessionModel> getCurrentSession() async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM session WHERE close_status = 0');
    if (maps.length > 0) {
      return SessionModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<SessionModel> getSingleSession(String id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM session WHERE id = "$id"');
    if (maps.length > 0) {
      return SessionModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<SessionModel> getListLast() async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM session ORDER BY id DESC LIMIT 1');
    if (maps.length > 0) {
      return SessionModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<SessionModel> getPreviousSession() async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM session WHERE close_status = 1 ORDER BY id DESC LIMIT 1');
    if (maps.length > 0) {
      return SessionModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateSession(SessionModel sessionModel) async {
    await openDb();
    return await _database
        .update('session', sessionModel.toMap(), where: "id = ?", whereArgs: [sessionModel.id]);
  }

  Future<void> deleteSession(int id) async {
    await openDb();
    await _database.delete('session', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Session Part Ends ////////////////
  ///
  ///
  ///////////////////////// Order Part Start ////////////////
  Future<int> makeOrder(OrderModel orderModel) async {
    await openDb();
    return await _database.insert('posOrder', orderModel.toMap());
  }

  Future<int> importOrder(OrderModel orderModel) async {
    await openDb();
    return await _database.insert('posOrder', orderModel.importToMap());
  }

//
  Future<List<OrderModel>> getOrderList() async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM posOrder WHERE payment_completion_status = 1 ORDER BY id DESC');
    return maps.map((m) => OrderModel.fromDb(m)).toList();
  }

  Future<List<OrderModel>> getOrderListAll() async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM posOrder');
    return maps.map((m) => OrderModel.fromDb(m)).toList();
  }

  Future<List<OrderModel>> getOrderListByDay(String day) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT * FROM posOrder WHERE payment_completion_status = 1 AND SUBSTR(timestamp, 1, 10) = "$day" AND order_subtotal > 0 ORDER BY id DESC');
    return maps.map((m) => OrderModel.fromDb(m)).toList();
  }

  Future<List<OrderModel>> getReturnListByMonth(String month, String filterType) async {
    await openDb();
    if (filterType == "month") {
      var maps = await _database.rawQuery(
          'SELECT * FROM posOrder WHERE payment_completion_status = 1 AND SUBSTR(timestamp, 1, 7) = "$month" AND order_subtotal < 0  ORDER BY id DESC');
      return maps.map((m) => OrderModel.fromDb(m)).toList();
    } else {
      var maps = await _database.rawQuery(
          'SELECT * FROM posOrder WHERE payment_completion_status = 1 AND SUBSTR(timestamp, 1, 4) = "$month" AND order_subtotal < 0  ORDER BY id DESC');
      return maps.map((m) => OrderModel.fromDb(m)).toList();
    }
  }

  Future<OrderModel> getSingleOrder(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM posOrder WHERE id = $id');
    if (maps.length > 0) {
      return OrderModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<OrderModel> getSingleOrderByQr(String qr) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM posOrder WHERE qr_code_string = "$qr"');
    if (maps.length > 0) {
      return OrderModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<OrderModel> getOrderListLast() async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM posOrder ORDER BY id DESC LIMIT 1');
    if (maps.length > 0) {
      return OrderModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<double> getSessionOrderSubtotal(int sessionId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(order_subtotal) AS sumValue FROM posOrder WHERE session_id = $sessionId');
    double count = maps[0]['sumValue'];
    return count;
  }

  Future<int> getSessionOrderNo(int sessionId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(order_item_no) AS sumValue FROM posOrder WHERE session_id = $sessionId');
    int count = maps[0]['sumValue'];

    return count;
  }

  Future<double> getSessionOrderPurchaseTotal(int sessionId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(order_purchase_price_total) AS sumValue FROM posOrder WHERE session_id = $sessionId');
    double count = maps[0]['sumValue'];
    return count;
  }

  Future<double> getSessionOrderDiscount(int sessionId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(order_discount) AS sumValue FROM posOrder WHERE session_id = $sessionId');
    double count = maps[0]['sumValue'];
    return count;
  }

  Future<List<OrderModel>> getSingleSessionOrderList(int sessionId) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM posOrder WHERE session_id = $sessionId');
    return maps.map((m) => OrderModel.fromDb(m)).toList();
  }

  Future<int> updateOrder(OrderModel orderModel) async {
    await openDb();
    return await _database
        .update('posOrder', orderModel.toMap(), where: "id = ?", whereArgs: [orderModel.id]);
  }

  Future<void> deleteOrder(int id) async {
    await openDb();
    await _database.delete('posOrder', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Order Part Ends ////////////////
  ///
  ///
  /// ////////////////////// Expense Part Start ////////////////
  Future<int> insertExpense(ExpenseModel expenseModel) async {
    await openDb();
    return await _database.insert('expense', expenseModel.toMap());
  }

  Future<int> importExpense(ExpenseModel expenseModel) async {
    await openDb();
    return await _database.insert('expense', expenseModel.importToMap());
  }

  Future<List<ExpenseModel>> getExpenseList(String type, String timeObject) async {
    await openDb();
    if (type == "daily") {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
          'SELECT * FROM expense WHERE expense_type = "$type" AND SUBSTR(timestamp, 1, 10) = "$timeObject" ORDER BY id DESC');
      return maps.map((m) => ExpenseModel.fromDb(m)).toList();
    } else {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
          'SELECT * FROM expense WHERE expense_type = "$type" AND SUBSTR(timestamp, 1, 4) = "$timeObject" ORDER BY id DESC');
      return maps.map((m) => ExpenseModel.fromDb(m)).toList();
    }
  }

  Future<List<ExpenseModel>> getExpenseAllList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery('SELECT * FROM expense');
    return maps.map((m) => ExpenseModel.fromDb(m)).toList();
  }

  Future<double> getSessionDailyExpense(int sessionId, String expenseType) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(amount) AS sumValue  FROM expense WHERE session_id = $sessionId AND expense_type = "$expenseType"');
    double tempVal = maps[0]['sumValue'] == null ? 0.0 : maps[0]['sumValue'];
    return tempVal;
  }

  Future<double> getExpenseSum(String type, String timeObject) async {
    await openDb();
    if (type == "daily") {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
          'SELECT SUM(amount) AS sumValue  FROM expense WHERE expense_type = "$type" AND SUBSTR(timestamp, 1, 10) = "$timeObject"');
      double tempVal = maps[0]['sumValue'] == null ? 0.0 : maps[0]['sumValue'];
      return tempVal;
    } else {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
          'SELECT SUM(amount) AS sumValue  FROM expense WHERE expense_type = "$type" AND SUBSTR(timestamp, 1, 4) = "$timeObject"');
      double tempVal = maps[0]['sumValue'] == null ? 0.0 : maps[0]['sumValue'];
      return tempVal;
    }
  }

  Future<int> updateExpense(ExpenseModel expenseModel) async {
    await openDb();
    return await _database
        .update('expense', expenseModel.toMap(), where: "id = ?", whereArgs: [expenseModel.id]);
  }

  Future<void> deleteExpense(int id) async {
    await openDb();
    await _database.delete('expense', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Expense Part Ends ////////////////
  ///
  ///////////////////////// selectedProductVariant Part Start ////////////////
  Future<int> insertSelectedProductVariant(
      SelectedProductVariantModel selectedProductVariantModel) async {
    await openDb();
    return await _database.insert('selectedProductVariant', selectedProductVariantModel.toMap());
  }

  Future<int> importSelectedProductVariant(
      SelectedProductVariantModel selectedProductVariantModel) async {
    await openDb();
    return await _database.insert(
        'selectedProductVariant', selectedProductVariantModel.importToMap());
  }

  Future<List<SelectedProductVariantModel>> getSelectedProductVariantList() async {
    await openDb();
    // deleteDB(); //delete the entire database
    final List<Map<String, dynamic>> maps = await _database.query('selectedProductVariant');
    return maps.map((m) => SelectedProductVariantModel.fromDb(m)).toList();
  }

  Future<List<SelectedProductVariantModel>> getSelectedProductVariantListById(
      int shoppingCartProductId, int productId, int shoppingCartId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT * FROM selectedProductVariant WHERE product_id = $productId AND shopping_cart_id = $shoppingCartId AND shopping_cart_product_id = $shoppingCartProductId');
    return maps.map((m) => SelectedProductVariantModel.fromDb(m)).toList();
  }

  Future<List<SelectedProductVariantModel>> getSelectedProductVariantListByProductId(
      int productId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database
        .rawQuery('SELECT * FROM selectedProductVariant WHERE product_id = $productId');
    return maps.map((m) => SelectedProductVariantModel.fromDb(m)).toList();
  }

  Future<List<SelectedProductVariantModel>> getSelectedProductVariantListByFiveId(
      int shoppingCartId,
      int productId,
      int shoppingCartProductId,
      int variantId,
      int optionId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT * FROM selectedProductVariant WHERE product_id = $productId AND shopping_cart_id = $shoppingCartId AND variant_id = $variantId AND option_id = $optionId AND shopping_cart_product_id = $shoppingCartProductId');

    return maps.map((m) => SelectedProductVariantModel.fromDb(m)).toList();
  }

  Future<int> updateSelectedProductVariant(
      SelectedProductVariantModel selectedProductVariantModel) async {
    await openDb();
    return await _database.update('selectedProductVariant', selectedProductVariantModel.toMap(),
        where: "id = ?", whereArgs: [selectedProductVariantModel.id]);
  }

  Future<void> deleteSelectedProductVariant(int id) async {
    await openDb();
    await _database.delete('selectedProductVariant', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// selectedProductVariant Part Ends ////////////////

  /// ////////////////////// Dashboard Section Part Start ////////////////

  Future<double> getSessionMonthlyRevenue(String timeStampYear, String timeStampMonth) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(order_subtotal) AS sumValue FROM posOrder WHERE SUBSTR(timestamp, 1, 4) = "$timeStampYear" AND SUBSTR(timestamp, 6, 2) = "$timeStampMonth"');
    double revenueTemp = maps[0]['sumValue'];
    if (revenueTemp == null) {
      revenueTemp = 0;
    } else {
      revenueTemp = revenueTemp;
    }

    // for expense of that month
    var maps1 = await _database.rawQuery(
        'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 1, 4) = "$timeStampYear" AND SUBSTR(timestamp, 6, 2) = "$timeStampMonth" AND expense_type = "monthly"');
    double expenseAmount = maps1[0]['sumValue'];
    if (expenseAmount == null) {
      expenseAmount = 0;
    } else {
      expenseAmount = expenseAmount;
    }

    return (revenueTemp - expenseAmount);
  }

  ////anuual net revenue
  Future<double> getAnnualRevenue(String timeStampYear) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(order_subtotal) AS sumValue FROM posOrder WHERE SUBSTR(timestamp, 1, 4) = "$timeStampYear"');
    double revenueTemp = maps[0]['sumValue'];
    if (revenueTemp == null) {
      revenueTemp = 0.0;
    } else {
      revenueTemp = revenueTemp;
    }

    // for expense of that month
    var maps1 = await _database.rawQuery(
        'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 1, 4) = "$timeStampYear"');
    double expenseAmount = maps1[0]['sumValue'];
    if (expenseAmount == null) {
      expenseAmount = 0.0;
    } else {
      expenseAmount = expenseAmount;
    }

    return revenueTemp - expenseAmount;
  }

  Future<double> getMonthlyExpense(String timeStampMonth) async {
    await openDb();
    var maps1 = await _database.rawQuery(
        'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 6, 2) = "$timeStampMonth"');
    double tempVale = maps1[0]['sumValue'];
    return tempVale;
  }

  Future<int> getProductsNo() async {
    await openDb();
    // for expense of that month
    var maps1 = await _database.rawQuery('SELECT COUNT(*) FROM product');
    int count = Sqflite.firstIntValue(maps1);
    return count == null ? 0 : count;
  }

  Future<int> getNoteNo() async {
    await openDb();
    var maps1 = await _database.rawQuery('SELECT COUNT(*) FROM notification');
    int count = Sqflite.firstIntValue(maps1);
    return count == null ? 0 : count;
  }

  Future<int> getCategoriesNo() async {
    await openDb();
    // for expense of that month
    var maps1 = await _database.rawQuery('SELECT COUNT(*) FROM category');
    int count = Sqflite.firstIntValue(maps1);
    return count == null ? 0 : count;
  }

  Future<double> getMonthlyRevenue(String yearMonthStamp) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT SUM(order_subtotal) AS sumValue FROM posOrder WHERE SUBSTR(timestamp, 1, 7) = "$yearMonthStamp"');
    double revenueTemp = maps[0]['sumValue'];
    if (revenueTemp == null) {
      revenueTemp = 0;
    } else {
      revenueTemp = revenueTemp;
    }

    // for expense of that month
    var maps1 = await _database.rawQuery(
        'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 1, 7) = "$yearMonthStamp"');
    double expenseAmount = maps1[0]['sumValue'];
    if (expenseAmount == null) {
      expenseAmount = 0;
    } else {
      expenseAmount = expenseAmount;
    }

    return revenueTemp - expenseAmount;
  }

  Future<int> getMonthlySessionNo(String yearMonthStamp) async {
    await openDb();
    // for expense of that month
    var maps1 = await _database.rawQuery(
        'SELECT COUNT(*) FROM session WHERE SUBSTR(opening_time, 1, 7) = "$yearMonthStamp"');
    int count = Sqflite.firstIntValue(maps1);
    return count;
  }

  Future<int> getMonthlyOrderNo(String yearMonthStamp) async {
    await openDb();
    // for expense of that month
    var maps1 = await _database.rawQuery(
        'SELECT COUNT(*) FROM posOrder WHERE SUBSTR(timestamp, 1, 7) = "$yearMonthStamp" AND payment_completion_status = 1 AND order_subtotal > 0');
    int count = Sqflite.firstIntValue(maps1);
    return count == null ? 0 : count;
  }

  Future<int> getMonthlyReturnNo(String yearMonthStamp) async {
    await openDb();
    var maps1 = await _database.rawQuery(
        'SELECT COUNT(*) FROM posOrder WHERE SUBSTR(timestamp, 1, 7) = "$yearMonthStamp" AND order_subtotal < 0');
    int count = Sqflite.firstIntValue(maps1);
    return count == null ? 0 : count;
  }

  Future<int> getHoldNo() async {
    await openDb();
    var maps1 = await _database
        .rawQuery('SELECT COUNT(*) FROM shoppingCart WHERE checked_out = 0 AND on_hold = 1');
    int count = Sqflite.firstIntValue(maps1);
    return count == null ? 0 : count;
  }

  Future<int> getInvoiceNo() async {
    await openDb();
    var maps1 =
        await _database.rawQuery('SELECT COUNT(*) FROM invoice WHERE invoice_paid_status = 0');
    int count = Sqflite.firstIntValue(maps1);
    return count == null ? 0 : count;
  }

  ////////////////////// Category Part Ends ////////////////
  ///
  ///
  /////////////////// Analytics Part stars ////////////////////////

  Future<List<InventoryModel>> getInventoryList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        // 'SELECT product.name, product.quantity, SUM(shoppingCartProduct.product_quantity) AS product_quantity, SUM(shoppingCartProduct.product_subtotal) AS product_subtotal, SUM(shoppingCartProduct.product_discount) AS product_discount FROM product INNER JOIN shoppingCartProduct ON product.id = shoppingCartProduct.product_id GROUP BY product.name ORDER BY SUM(shoppingCartProduct.product_quantity) DESC');
        'SELECT product.name, product.quantity, SUM(shoppingCartProduct.product_quantity) AS product_quantity, SUM(shoppingCartProduct.product_subtotal) AS product_subtotal, SUM(shoppingCartProduct.product_discount) AS product_discount FROM product INNER JOIN shoppingCartProduct ON product.id = shoppingCartProduct.product_id INNER JOIN posOrder ON posOrder.cart_id = shoppingCartProduct.shopping_cart_id WHERE posOrder.order_subtotal > 0 GROUP BY product.name ORDER BY SUM(shoppingCartProduct.product_quantity) DESC');
    return maps.map((m) => InventoryModel.fromDb(m)).toList();
  }

////////////////// Analytics Part ends /////////////////////
  ///
  ///
///////////////// Annual net revenue starts ////////////////////////

  Future<List<SessionModel>> getAllSessionList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('session');
    return maps.map((m) => SessionModel.fromDb(m)).toList();
  }

  ////Monthly Graph net revenue
  Future<List<NetRevenue>> getMonthlyGraphRevenue(Map<String, double> myDataApp) async {
    List<NetRevenue> netRevenueListDB = List();
    await openDb();
    for (String key in myDataApp.keys) {
      var maps = await _database.rawQuery(
          'SELECT SUM(order_subtotal) AS sumValue FROM posOrder WHERE SUBSTR(timestamp, 1, 7) = "$key"');
      double revenueTemp = maps[0]['sumValue'];
      if (revenueTemp == null) {
        revenueTemp = 0;
      } else {
        revenueTemp = revenueTemp;
      }

      // for expense of that month
      var maps1 = await _database.rawQuery(
          'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 1, 7) = "$key"');
      double expenseAmount = maps1[0]['sumValue'];
      if (expenseAmount == null) {
        expenseAmount = 0;
      } else {
        expenseAmount = expenseAmount;
      }
      myDataApp[key] = revenueTemp - expenseAmount;
    }
    for (String key in myDataApp.keys) {
      netRevenueListDB.add(NetRevenue(key, myDataApp[key]));
    }
    return netRevenueListDB;
  }

  ////Monthly Graph Expense
  Future<List<Expense>> getMonthlyGraphExpense(Map<String, double> myDataApp) async {
    List<Expense> expenseListDB = List();
    await openDb();
    for (String key in myDataApp.keys) {
      // for expense of that month
      var maps1 = await _database.rawQuery(
          'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 1, 7) = "$key"');
      double expenseAmount = maps1[0]['sumValue'];
      if (expenseAmount == null) {
        expenseAmount = 0;
      } else {
        expenseAmount = expenseAmount;
      }
      myDataApp[key] = expenseAmount;
    }
    for (String key in myDataApp.keys) {
      expenseListDB.add(Expense(key, myDataApp[key]));
    }
    return expenseListDB;
  }

  ////Monthly Graph net revenue
  Future<List<Profit>> getMonthlyGraphProfit(Map<String, double> myDataApp) async {
    List<Profit> profitListDB = List();
    await openDb();
    for (String key in myDataApp.keys) {
      var maps = await _database.rawQuery(
          'SELECT SUM(order_purchase_price_total) AS purchaseValue, SUM(order_subtotal) AS netValue FROM posOrder WHERE SUBSTR(timestamp, 1, 7) = "$key"');
      double purchaseTemp = maps[0]['purchaseValue'];
      double netRevenueTemp = maps[0]['netValue'];

      //purchase price
      if (purchaseTemp == null) {
        purchaseTemp = 0;
      } else {
        purchaseTemp = purchaseTemp;
      }
      //Net Revenue
      if (netRevenueTemp == null) {
        netRevenueTemp = 0;
      } else {
        netRevenueTemp = netRevenueTemp;
      }

      // for expense of that month
      var maps1 = await _database.rawQuery(
          'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 1, 7) = "$key"');
      double expenseAmount = maps1[0]['sumValue'];
      if (expenseAmount == null) {
        expenseAmount = 0;
      } else {
        expenseAmount = expenseAmount;
      }

      myDataApp[key] = netRevenueTemp - expenseAmount - purchaseTemp;
    }
    for (String key in myDataApp.keys) {
      profitListDB.add(Profit(key, myDataApp[key]));
    }
    return profitListDB;
  }

  ////Anuual Graph net revenue, expenses and profit
  Future<List<MonthlyDateModel>> getAnnualGraphSale(Map<String, double> myDataApp) async {
    // List<NetRevenue> netRevenueListDB = List();
    List<MonthlyDateModel> annualExpenseRevenue = List();
    await openDb();
    for (String key in myDataApp.keys) {
      // for expense of that month
      var maps1 = await _database.rawQuery(
          'SELECT SUM(amount) AS sumValue FROM expense WHERE SUBSTR(timestamp, 1, 7) = "$key"');
      double expenseAmount = maps1[0]['sumValue'];
      if (expenseAmount == null) {
        expenseAmount = 0;
      } else {
        expenseAmount = expenseAmount;
      }

      ////for monthly profit and net_revenue
      var profitMap = await _database.rawQuery(
          'SELECT SUM(order_purchase_price_total) AS purchaseValue, SUM(order_subtotal) AS netValue FROM posOrder WHERE SUBSTR(timestamp, 1, 7) = "$key"');
      double purchaseTemp = profitMap[0]['purchaseValue'];
      double netRevenueTemp = profitMap[0]['netValue'];

      //purchase price
      if (purchaseTemp == null) {
        purchaseTemp = 0;
      } else {
        purchaseTemp = purchaseTemp;
      }
      //Net Revenue
      if (netRevenueTemp == null) {
        netRevenueTemp = 0;
      } else {
        netRevenueTemp = netRevenueTemp;
      }

      ///Adding to final list
      annualExpenseRevenue.add(MonthlyDateModel(
          expense: expenseAmount,
          revenue: netRevenueTemp - expenseAmount,
          profit: netRevenueTemp - expenseAmount - purchaseTemp,
          year: key));
    }
    return annualExpenseRevenue;
  }

  ///////// Annual net Revenue ends /////////////////////
  ///
  ///////////////////////// Barcode Part Start ////////////////
  Future<int> insertBarcode(BarcodeModel barcodeModel) async {
    await openDb();
    return await _database.insert('barcode', barcodeModel.toMap());
  }

  Future<int> importBarcode(BarcodeModel barcodeModel) async {
    await openDb();
    return await _database.insert('barcode', barcodeModel.importToMap());
  }

  Future<List<BarcodeModel>> getBarcodeList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('barcode');
    return maps.map((m) => BarcodeModel.fromDb(m)).toList();
  }

  Future<BarcodeModel> getSingleBarcode(String barcodeString) async {
    await openDb();
    var maps =
        await _database.rawQuery('SELECT * FROM barcode WHERE barcode_text = "$barcodeString"');
    if (maps.length > 0) {
      return BarcodeModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<BarcodeModel> getSingleBarcodeByName(int productId) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM barcode WHERE product_id = $productId');
    if (maps.length > 0) {
      return BarcodeModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateBarcode(BarcodeModel barcodeModel) async {
    await openDb();
    return await _database
        .update('barcode', barcodeModel.toMap(), where: "id = ?", whereArgs: [barcodeModel.id]);
  }

  Future<void> deleteBarcode(int id) async {
    await openDb();
    await _database.delete('barcode', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Barcode Part Ends ////////////////
  ///
  //////////////////////////// Qrcode Part Start ////////////////
  Future<int> insertQrcode(QrcodeModel qrcodeModel) async {
    await openDb();
    return await _database.insert('qrCode', qrcodeModel.toMap());
  }

  Future<int> importQrcode(QrcodeModel qrcodeModel) async {
    await openDb();
    return await _database.insert('qrCode', qrcodeModel.importToMap());
  }

  Future<List<QrcodeModel>> getQrcodeList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('qrCode');
    return maps.map((m) => QrcodeModel.fromDb(m)).toList();
  }

  Future<QrcodeModel> getSingleQrcode(String qrData) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM qrCode WHERE qr_data = "$qrData"');
    if (maps.length > 0) {
      return QrcodeModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateQrcode(QrcodeModel qrcodeModel) async {
    await openDb();
    return await _database
        .update('qrCode', qrcodeModel.toMap(), where: "id = ?", whereArgs: [qrcodeModel.id]);
  }

  Future<void> deleteQrcode(int id) async {
    await openDb();
    await _database.delete('qrCode', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Qrcode Part Ends ////////////////
  ///
  //////////////////Invoicing part starts /////////////////////////

  Future<List<ProductShoppingCartInvoicing>> getProductShoppingCartListInvoicing(
      int shoppingCartId) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT product.name, product.alias, product.price, product.has_variant, shoppingCartProduct.product_quantity, shoppingCartProduct.product_subtotal, shoppingCartProduct.product_discount, shoppingCartProduct.has_variant_option FROM product INNER JOIN shoppingCartProduct ON product.id = shoppingCartProduct.product_id WHERE shoppingCartProduct.shopping_cart_id = $shoppingCartId');
    return maps.map((m) => ProductShoppingCartInvoicing.fromDb(m)).toList();
  }

  /////////////////Invoicing part ends /////////////////////////
  ///
  ////// ////////////////////// Invoice Part Start ////////////////
  Future<int> insertInvoice(InvoiceModel invoiceModel) async {
    await openDb();
    return await _database.insert('invoice', invoiceModel.toMap());
  }

  Future<int> importInvoice(InvoiceModel invoiceModel) async {
    await openDb();
    return await _database.insert('invoice', invoiceModel.importToMap());
  }

  Future<List<InvoiceModel>> getInvoiceList() async {
    await openDb();
    // final List<Map<String, dynamic>> maps = await _database.query('invoice');
    var maps = await _database
        .rawQuery('SELECT * FROM invoice WHERE invoice_paid_status = 0 ORDER BY id DESC');
    return maps.map((m) => InvoiceModel.fromDb(m)).toList();
  }

  Future<List<InvoiceModel>> getInvoiceListAll() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('invoice');
    return maps.map((m) => InvoiceModel.fromDb(m)).toList();
  }

  Future<InvoiceModel> getSingleInvoice(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM invoice WHERE id = $id');
    if (maps.length > 0) {
      return InvoiceModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<InvoiceModel> getSingleInvoiceByQr(String qr) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM invoice WHERE qr_code_string = "$qr"');
    if (maps.length > 0) {
      return InvoiceModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateInvoice(InvoiceModel invoiceModel) async {
    await openDb();
    return await _database
        .update('invoice', invoiceModel.toMap(), where: "id = ?", whereArgs: [invoiceModel.id]);
  }

  Future<void> deleteInvoice(int id) async {
    await openDb();
    await _database.delete('invoice', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Invoice Part Ends ////////////////
  ///
  /// ///////////////////////// Notification Part Start ////////////////
  Future<int> createNotification(NotificationModel notificationModel) async {
    await openDb();
    return await _database.insert('notification', notificationModel.toMap());
  }

  Future<int> importNotification(NotificationModel notificationModel) async {
    await openDb();
    return await _database.insert('notification', notificationModel.importToMap());
  }

  Future<List<NotificationModel>> getNotificationList() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM notification ORDER BY id DESC');
    return maps.map((m) => NotificationModel.fromDb(m)).toList();
  }

  Future<NotificationModel> getSingleNotification(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM notification WHERE id = $id');
    if (maps.length > 0) {
      return NotificationModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<NotificationModel> getSingleNotificationByType(String id, String type) async {
    await openDb();
    var maps = await _database
        .rawQuery('SELECT * FROM notification WHERE detail_id = "$id" AND note_type = "$type"');
    if (maps.length > 0) {
      return NotificationModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<NotificationModel> getSingleNotificationByProduct(
      String id, String type, int noteId) async {
    await openDb();
    var maps = await _database.rawQuery(
        'SELECT * FROM notification WHERE id = $noteId AND detail_id = "$id" AND note_type = "$type"');
    if (maps.length > 0) {
      return NotificationModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<void> clearNotification(int id) async {
    await openDb();
    await _database.delete('notification', where: "id = ?", whereArgs: [id]);
  }

  Future<void> clearAllNotification() async {
    await openDb();
    await _database.rawQuery('DELETE FROM notification');
  }

  Future<int> updateNote(NotificationModel noteModel) async {
    await openDb();
    return await _database
        .update('notification', noteModel.toMap(), where: "id = ?", whereArgs: [noteModel.id]);
  }

  ////////////////////// Notification Part Ends ////////////////
  ///
  //////////////////////////// User Part Start ////////////////
  Future<int> createUser(UserModel userModel) async {
    await openDb();
    return await _database.insert('user', userModel.toMap());
  }

  Future<UserModel> getSingleUser() async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM user LIMIT 1');
    if (maps.length > 0) {
      return UserModel.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateUser(UserModel userModel) async {
    await openDb();
    return await _database
        .update('user', userModel.toMap(), where: "id = ?", whereArgs: [userModel.id]);
  }

  Future<void> deleteUser(int id) async {
    await openDb();
    await _database.delete('user', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// User Part Ends ////////////////
  ///
  ///  ////////////////////// Language Part Start ////////////////
  Future<int> createLaguages(AppLanguage appLanguage) async {
    await openDb();
    return await _database.insert('appLanguage', appLanguage.toMap());
  }

  Future<List<AppLanguage>> getLanguageList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('appLanguage');
    return maps.map((m) => AppLanguage.fromDb(m)).toList();
  }

  Future<AppLanguage> getActiveLanguage() async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM appLanguage WHERE active = 1 LIMIT 1');
    if (maps.length > 0) {
      return AppLanguage.fromDb(maps[0]);
    }
    return null;
  }

  Future<AppLanguage> getSigleLanguage(String code) async {
    await openDb();
    var maps =
        await _database.rawQuery('SELECT * FROM appLanguage WHERE language_code = "$code" LIMIT 1');
    if (maps.length > 0) {
      return AppLanguage.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateLanguage(AppLanguage appLanguage) async {
    await openDb();
    return await _database
        .update('appLanguage', appLanguage.toMap(), where: "id = ?", whereArgs: [appLanguage.id]);
  }

  ////////////////////// Language Part Ends ////////////////
  ///
  ///////////////////////// Logs Part Start ////////////////
  Future<int> createLog(Logs logs) async {
    await openDb();
    return await _database.insert('allLogs', logs.toMap());
  }

  Future<List<Logs>> getAllLogs() async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM allLogs ORDER BY id DESC');
    return maps.map((m) => Logs.fromDb(m)).toList();
  }

  Future<int> importAllLogs(Logs logs) async {
    await openDb();
    return await _database.insert('allLogs', logs.importToMap());
  }

  Future<void> deleteLog(int id) async {
    await openDb();
    await _database.delete('allLogs', where: "id = ?", whereArgs: [id]);
  }

  ////////////////////// Logs Part Ends ////////////////
  ///
  /// ///////////////////////// ProductLog Part Start ////////////////
  Future<int> createProductLog(ProductLog productLog) async {
    await openDb();
    return await _database.insert('productLog', productLog.toMap());
  }

  Future<List<ProductLog>> getProductLogList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery('SELECT * FROM productLog');
    return maps.map((m) => ProductLog.fromDb(m)).toList();
  }

  Future<ProductLog> getSingleProductLog(int id) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM productLog WHERE all_log_id = $id');
    if (maps.length > 0) {
      return ProductLog.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> importProductLog(ProductLog productLog) async {
    await openDb();
    return await _database.insert('productLog', productLog.importToMap());
  }

  ////////////////////// ProductLog Part Ends ////////////////
  ///
  ////// ///////////////////////// LogActivation Part Start ////////////////
  Future<int> createLogActivation(LogActivation logActivation) async {
    await openDb();
    return await _database.insert('logActivation', logActivation.toMap());
  }

  Future<LogActivation> getLogActivation() async {
    await openDb();
    var maps = await _database.rawQuery('SELECT * FROM logActivation LIMIT 1');
    if (maps.length > 0) {
      return LogActivation.fromDb(maps[0]);
    }
    return null;
  }

  Future<int> updateLogActivation(LogActivation logActivation) async {
    await openDb();
    return await _database.update('logActivation', logActivation.toMap(),
        where: "id = ?", whereArgs: [logActivation.id]);
  }

  ////////////////////// LogActivation Part Ends ////////////////
  ///
  //////////////////////////// BackupHistory Part Start ////////////////
  Future<int> createBackupHistory(BackupHistory backupHistory) async {
    await openDb();
    return await _database.insert('backupHistory', backupHistory.toMap());
  }

  Future<List<BackupHistory>> getAllBackupHistory(String model, String operation) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT * FROM backupHistory WHERE model = "$model" AND operation = "$operation"');
    if (maps.length > 0) {
      return maps.map((m) => BackupHistory.fromDb(m)).toList();
    }
    return null;
  }

  Future<BackupHistory> getHistoryByOperation(String operation, String model, int modelId) async {
    await openDb();
    if (operation != "Add") {
      var maps = await _database.rawQuery(
          'SELECT * FROM backupHistory WHERE operation = "$operation" AND model = "$model" AND model_id=$modelId');
      if (maps.length > 0) {
        return BackupHistory.fromDb(maps[0]);
      }
      return null;
    } else {
      var maps1 = await _database.rawQuery(
          'SELECT * FROM backupHistory WHERE operation = "$operation" AND model = "$model"');
      if (maps1.length > 0) {
        return BackupHistory.fromDb(maps1[0]);
      }
      return null;
    }
  }

  Future<int> updateBackupHistory(BackupHistory backupHistory) async {
    await openDb();
    return await _database.update('backupHistory', backupHistory.toMap(),
        where: "id = ?", whereArgs: [backupHistory.id]);
  }

  Future<void> deleteBackupUpdationHistory(String model, String operation) async {
    await openDb();
    await _database
        .rawQuery('DELETE FROM backupHistory WHERE operation="$operation" AND model="$model"');
  }

  Future<void> deleteBackupAllHistory() async {
    await openDb();
    await _database.rawQuery('DELETE FROM backupHistory');
  }

  Future<List<Category>> getEditedCategory(String model, String operation) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT category.id AS id, name, include_in_drawer FROM category INNER JOIN backupHistory ON category.id = backupHistory.model_id WHERE backupHistory.model = "$model" AND backupHistory.operation = "$operation"');
    return maps.map((m) => Category.fromDb(m)).toList();
  }

  Future<List<Variant>> getEditedVariant(String model, String operation) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT variant.id AS id, name FROM variant INNER JOIN backupHistory ON variant.id = backupHistory.model_id WHERE backupHistory.model = "$model" AND backupHistory.operation = "$operation"');
    return maps.map((m) => Variant.fromDb(m)).toList();
  }

  Future<List<Product>> getEditedProduct(String model, String operation) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT product.id AS id, name, alias, purchase, price, picture, barcode, enable_product, quantity, weight, has_variant FROM product INNER JOIN backupHistory ON product.id = backupHistory.model_id WHERE backupHistory.model = "$model" AND backupHistory.operation = "$operation"');
    return maps.map((m) => Product.fromDb(m)).toList();
  }

  Future<List<SessionModel>> getEditedSession(String model, String operation) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT session.id AS id, opening_balance, opening_time, closing_time, session_comment, close_status, drawer_status FROM session INNER JOIN backupHistory ON session.id = backupHistory.model_id WHERE backupHistory.model = "$model" AND backupHistory.operation = "$operation"');
    return maps.map((m) => SessionModel.fromDb(m)).toList();
  }

  Future<List<ExpenseModel>> getEditedExpense(String model, String operation) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT expense.id AS id, expense_type, reason, amount, timestamp, session_id FROM expense INNER JOIN backupHistory ON expense.id = backupHistory.model_id WHERE backupHistory.model = "$model" AND backupHistory.operation = "$operation"');
    return maps.map((m) => ExpenseModel.fromDb(m)).toList();
  }

  Future<List<InvoiceModel>> getEditedInvoice(String model, String operation) async {
    print('insid ehte getEditedInvoice');
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery(
        'SELECT invoice.id AS id, invoice_subtotal, invoice_discount, invoice_paid_amount, invoice_payable_amount, invoice_item_no, customer_name, customer_address, customer_phone, customer_email, qr_code_string, invoice_number, invoice_issue_date, invoice_due_date, invoice_paid_status, cart_id, session_id, order_id FROM invoice INNER JOIN backupHistory ON invoice.id = backupHistory.model_id WHERE backupHistory.model = "$model" AND backupHistory.operation = "$operation"');
    return maps.map((m) => InvoiceModel.fromDb(m)).toList();
  }

  Future<int> getMaxId(String table) async {
    await openDb();
    var maps = await _database.rawQuery('SELECT MAX(id) AS maxId FROM "$table"');

    if (maps[0]['maxId'] != null) {
      return maps[0]['maxId'];
    }
    return null;
  }

  ////////////////////// BackupHistory Part Ends ////////////////
  ///
  ///////////////// Backup By Max ID ////////////////////

  Future<List<Category>> getCategoryMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM category WHERE id > $maxId');
    return maps.map((m) => Category.fromDb(m)).toList();
  }

  Future<List<Variant>> getVariantMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM variant WHERE id > $maxId');
    return maps.map((m) => Variant.fromDb(m)).toList();
  }

  Future<List<VariantOption>> getVariantOptionMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM variantOption WHERE id > $maxId');
    return maps.map((m) => VariantOption.fromDb(m)).toList();
  }

  Future<List<Product>> getProductMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM product WHERE id > $maxId');
    return maps.map((m) => Product.fromDb(m)).toList();
  }

  Future<List<CategoryProductJoin>> getCategoryProducttMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM categoryProduct WHERE id > $maxId');
    return maps.map((m) => CategoryProductJoin.fromDb(m)).toList();
  }

  Future<List<VariantProductJoin>> getVariantProductMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM variantProduct WHERE id > $maxId');
    return maps.map((m) => VariantProductJoin.fromDb(m)).toList();
  }

  Future<List<ProductVariantOption>> getProductVariantOptionMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM productVariantOption WHERE id > $maxId');
    return maps.map((m) => ProductVariantOption.fromDb(m)).toList();
  }

  Future<List<ShoppingCartModel>> getShoppingCartMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM shoppingCart WHERE id > $maxId');
    return maps.map((m) => ShoppingCartModel.fromDb(m)).toList();
  }

  Future<List<ShoppingCartProductModel>> getShoppingCartProductMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM shoppingCartProduct WHERE id > $maxId');
    return maps.map((m) => ShoppingCartProductModel.fromDb(m)).toList();
  }

  Future<List<SessionModel>> getSessionMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM session WHERE id > $maxId');
    return maps.map((m) => SessionModel.fromDb(m)).toList();
  }

  Future<List<OrderModel>> getOrderMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM posOrder WHERE id > $maxId');
    return maps.map((m) => OrderModel.fromDb(m)).toList();
  }

  Future<List<ExpenseModel>> getExpenseMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM expense WHERE id > $maxId');
    return maps.map((m) => ExpenseModel.fromDb(m)).toList();
  }

  Future<List<SelectedProductVariantModel>> getSelectedProductVariantMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM selectedProductVariant WHERE id > $maxId');
    return maps.map((m) => SelectedProductVariantModel.fromDb(m)).toList();
  }

  Future<List<BarcodeModel>> getBarcodeMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM barcode WHERE id > $maxId');
    return maps.map((m) => BarcodeModel.fromDb(m)).toList();
  }

  Future<List<Logs>> getLogMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM allLogs WHERE id > $maxId');
    return maps.map((m) => Logs.fromDb(m)).toList();
  }

  Future<List<ProductLog>> getProductLogMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM productLog WHERE id > $maxId');
    return maps.map((m) => ProductLog.fromDb(m)).toList();
  }

  Future<List<InvoiceModel>> getInvoiceMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM invoice WHERE id > $maxId');
    return maps.map((m) => InvoiceModel.fromDb(m)).toList();
  }

  Future<List<NotificationModel>> getNoteMax(int maxId) async {
    await openDb();
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('SELECT * FROM notification WHERE id > $maxId');
    return maps.map((m) => NotificationModel.fromDb(m)).toList();
  }
}
