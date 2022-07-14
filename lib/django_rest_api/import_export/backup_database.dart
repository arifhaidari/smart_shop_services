import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/django_rest_api/services/barcode_service.dart';
import 'package:pos/django_rest_api/services/category_product_service.dart';
import 'package:pos/django_rest_api/services/category_service.dart';
import 'package:pos/django_rest_api/services/expense_service.dart';
import 'package:pos/django_rest_api/services/invoice_service.dart';
import 'package:pos/django_rest_api/services/logs_service.dart';
import 'package:pos/django_rest_api/services/notification_service.dart';
import 'package:pos/django_rest_api/services/order_service.dart';
import 'package:pos/django_rest_api/services/prodcut_variant_option_service.dart';
import 'package:pos/django_rest_api/services/product_log_service.dart';
import 'package:pos/django_rest_api/services/product_service.dart';
import 'package:pos/django_rest_api/services/selected_product_variant_service.dart';
import 'package:pos/django_rest_api/services/session_service.dart';
import 'package:pos/django_rest_api/services/shopping_cart_product_service.dart';
import 'package:pos/django_rest_api/services/shopping_cart_service.dart';
import 'package:pos/django_rest_api/services/variant_option_service.dart';
import 'package:pos/django_rest_api/services/variant_product_service.dart';
import 'package:pos/django_rest_api/services/variant_service.dart';

class BackupDatabase {
  final PosDatabase dbmanager = new PosDatabase();
  List<String> tableErrors = List();
  final LogAcitvity logActivity = new LogAcitvity();

  bool isLoading = false;

  // Services Objects
  final BarcodeModelService barcodeModelService = new BarcodeModelService();
  final CategoryProductJoinService categoryProductJoinService = new CategoryProductJoinService();
  final ProductVariantOptionService productVariantOptionService = new ProductVariantOptionService();
  final VariantProductJoinService variantProductJoinService = new VariantProductJoinService();
  final SelectedProductVariantModelService selectedProductVariantModelService =
      new SelectedProductVariantModelService();
  final ProductService productService = new ProductService();

  //################### Category

  final CategoryService categoryService = new CategoryService();
  Future<bool> postOnCategory(String token) async {
    // DELELE
    await dbmanager.getAllBackupHistory("Category", "Delete").then((value) {
      if (value != null) {
        value.forEach((element) async {
          await categoryService.deleteAPICategory(element.model_id, token).then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Category', 'Delete');
    });

    // UPDATE
    await dbmanager.getEditedCategory("Category", "Edit").then((value) {
      if (value != null) {
        value.forEach((elemnent) async {
          var mapData = {
            "category_pk": elemnent.id,
            "name": elemnent.name,
            "include_in_drawer": elemnent.include_in_drawer,
          };
          await categoryService
              .updateAPICategory(mapData, mapData['category_pk'], token)
              .then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Category', 'Edit');
    });

    // ADD
    // first get the max id
    await dbmanager.getHistoryByOperation('Add', 'category', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getCategoryMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "category_pk": value.id,
                "name": value.name,
                "include_in_drawer": value.include_in_drawer,
              };
              await categoryService.createAPICategory(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getCategoryList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "category_pk": value.id,
                "name": value.name,
                "include_in_drawer": value.include_in_drawer,
              };
              await categoryService.createAPICategory(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    // UPDATE the product quantity
    await dbmanager.getProductList().then((quantityList) {
      if (quantityList != null) {
        quantityList.forEach((value) async {
          var mapData = {
            "product_pk": value.id,
            "quantity": value.quantity,
          };
          await productService
              .updateAPIProduct(mapData, mapData['product_pk'], token)
              .then((onValue) async {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
    });
    // End of UPDATE the product quantity

    logActivity.recordBackupHistory('category', null, 'Add');
    return true;
  }

  //################### Variant
  final VariantService variantService = new VariantService();
  Future<bool> postOnVariant(String token) async {
    // DELELE
    await dbmanager.getAllBackupHistory("Variant", "Delete").then((value) {
      if (value != null) {
        value.forEach((element) async {
          await variantService.deleteAPIVariant(element.model_id, token).then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Variant', 'Delete');
    });

    // UPDATE
    await dbmanager.getEditedVariant("Variant", "Edit").then((value) {
      if (value != null) {
        value.forEach((element) async {
          var mapData = {
            "variant_pk": element.id,
            "name": element.name,
          };
          await variantService
              .updateAPIVariant(mapData, mapData['variant_pk'], token)
              .then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Variant', 'Edit');
    });

    // ADD
    await dbmanager.getHistoryByOperation('Add', 'variant', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getVariantMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "variant_pk": value.id,
                "name": value.name,
              };
              await variantService.createAPIVariant(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getVariantList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "variant_pk": value.id,
                "name": value.name,
              };
              await variantService.createAPIVariant(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });
    logActivity.recordBackupHistory('variant', null, 'Add');
    return true;
  }

  //################### VariantOption
  //only has Add operation
  final VariantOptionService variantOptionService = new VariantOptionService();
  Future<bool> postOnVariantOption(String token) async {
    // ADD
    await dbmanager.getHistoryByOperation('Add', 'variantOption', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getVariantOptionMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "variant_option_pk": value.id,
                "option_name": value.option_name,
                "variant_id": value.variant_id,
              };
              await variantOptionService.createAPIVariantOption(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getVariantOptionAllList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "variant_option_pk": value.id,
                "option_name": value.option_name,
                "variant_id": value.variant_id,
              };
              await variantOptionService.createAPIVariantOption(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
      //
    });

    logActivity.recordBackupHistory('variantOption', null, 'Add');
    return true;
  }

  //################### Product

  Future<bool> postOnProduct(String token) async {
    // DELELE
    await dbmanager.getAllBackupHistory("Product", "Delete").then((value) {
      if (value != null) {
        value.forEach((element) async {
          await productService.deleteAPIProduct(element.model_id, token).then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Product', 'Delete');
    });

    // UPDATE
    await dbmanager.getEditedProduct("Product", "Edit").then((editList) {
      if (editList != null) {
        editList.forEach((value) async {
          var mapData = {
            "product_pk": value.id,
            "name": value.name,
            "alias": value.alias,
            "purchase": value.purchase,
            "price": value.price,
            "picture": value.picture,
            "barcode": value.barcode,
            "enable_product": value.enable_product,
            "quantity": value.quantity,
            "weight": value.weight,
            "has_variant": value.has_variant,
          };
          await productService
              .updateAPIProduct(mapData, mapData['product_pk'], token)
              .then((onValue) async {
            // VariantProduct
            await dbmanager.getVariantProductListById(value.id).then((variantProductList) {
              if (variantProductList != null) {
                variantProductList.forEach((vpObject) async {
                  var mapData1 = {
                    "variant_product_pk": vpObject.id,
                    "variant_id": vpObject.variant_id,
                    "product_id": vpObject.product_id,
                  };
                  await variantProductJoinService
                      .createAPIVariantProductJoin(mapData1, token)
                      .then((onValue) {
                    if (onValue.error) {
                      tableErrors.add(onValue.errorMessage);
                    }
                  });
                });
              }
            });
            // ProductVariantOption
            await dbmanager.getProductVariantOptionListById(value.id).then((objectList1) {
              if (objectList1 != null) {
                objectList1.forEach((value1) async {
                  var mapData2 = {
                    "product_variant_option_pk": value1.id,
                    "product_id": value1.product_id,
                    "variant_id": value1.variant_id,
                    "option_id": value1.option_id,
                    "price": value1.price,
                  };
                  await productVariantOptionService
                      .createAPIProductVariantOption(mapData2, token)
                      .then((onValue) {
                    if (onValue.error) {
                      tableErrors.add(onValue.errorMessage);
                    }
                  });
                });
              }
            });

            // CategoryProduct
            await dbmanager.getCategoryProductListById(value.id).then((objectList2) {
              if (objectList2 != null) {
                objectList2.forEach((value2) async {
                  var mapData3 = {
                    "category_product_pk": value2.id,
                    "category_id": value2.category_id,
                    "product_id": value2.product_id,
                  };
                  await categoryProductJoinService
                      .createAPICategoryProductJoin(mapData3, token)
                      .then((onValue) {
                    if (onValue.error) {
                      tableErrors.add(onValue.errorMessage);
                    }
                  });
                });
              }
            });

            // Barcode
            await dbmanager.getSingleBarcodeByName(value.id).then((object3) async {
              if (object3 != null) {
                var mapData4 = {
                  "barcode_pk": object3.id,
                  "name": object3.name,
                  "product_id": object3.product_id,
                  "barcode_text": object3.barcode_text,
                };
                await barcodeModelService.createAPIBarcodeModel(mapData4, token).then((onValue) {
                  if (onValue.error) {
                    tableErrors.add(onValue.errorMessage);
                  }
                });
              }
            });
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Product', 'Edit');
    });

    // ADD
    await dbmanager.getHistoryByOperation('Add', 'product', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getProductMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "product_pk": value.id,
                "name": value.name,
                "alias": value.alias,
                "purchase": value.purchase,
                "price": value.price,
                "picture": value.picture,
                "barcode": value.barcode,
                "enable_product": value.enable_product,
                "quantity": value.quantity,
                "weight": value.weight,
                "has_variant": value.has_variant,
              };
              await productService.createAPIProduct(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getProductList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "product_pk": value.id,
                "name": value.name,
                "alias": value.alias,
                "purchase": value.purchase,
                "price": value.price,
                "picture": value.picture,
                "barcode": value.barcode,
                "enable_product": value.enable_product,
                "quantity": value.quantity,
                "weight": value.weight,
                "has_variant": value.has_variant,
              };
              await productService.createAPIProduct(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('product', null, 'Add');

    return true;
  }

  //################### CategoryProductJoin

  Future<bool> postOnCategoryProduct(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'categoryProduct', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getCategoryProducttMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "category_product_pk": value.id,
                "category_id": value.category_id,
                "product_id": value.product_id,
              };
              await categoryProductJoinService
                  .createAPICategoryProductJoin(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getCategoryProductList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "category_product_pk": value.id,
                "category_id": value.category_id,
                "product_id": value.product_id,
              };
              await categoryProductJoinService
                  .createAPICategoryProductJoin(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('categoryProduct', null, 'Add');

    return true;
  }

  //################### VariantProductJoin

  Future<bool> postOnVariantProduct(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'variantProduct', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getVariantProductMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "variant_product_pk": value.id,
                "variant_id": value.variant_id,
                "product_id": value.product_id,
              };
              await variantProductJoinService
                  .createAPIVariantProductJoin(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getVariantProductList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "variant_product_pk": value.id,
                "variant_id": value.variant_id,
                "product_id": value.product_id,
              };
              await variantProductJoinService
                  .createAPIVariantProductJoin(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('variantProduct', null, 'Add');

    return true;
  }

  //################### ProductVariantOption

  Future<bool> postOnProductVariantOption(String token) async {
    // Add
    await dbmanager
        .getHistoryByOperation('Add', 'productVariantOption', null)
        .then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getProductVariantOptionMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "product_variant_option_pk": value.id,
                "product_id": value.product_id,
                "variant_id": value.variant_id,
                "option_id": value.option_id,
                "price": value.price,
              };
              await productVariantOptionService
                  .createAPIProductVariantOption(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getProductVariantOptionList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "product_variant_option_pk": value.id,
                "product_id": value.product_id,
                "variant_id": value.variant_id,
                "option_id": value.option_id,
                "price": value.price,
              };
              await productVariantOptionService
                  .createAPIProductVariantOption(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('productVariantOption', null, 'Add');

    return true;
  }

  //################### ShoppingCartModel

  final ShoppingCartModelService shoppingCartModelService = new ShoppingCartModelService();
  Future<bool> postOnShoppingCart(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'shoppingCart', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getShoppingCartMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "shopping_cart_pk": value.id,
                "subtotal": value.subtotal,
                "cart_purchase_price_total": value.cart_purchase_price_total,
                "total_discount": value.total_discount,
                "cart_item_quantity": value.cart_item_quantity,
                "timestamp": value.timestamp,
                "checked_out": value.checked_out,
                "on_hold": value.on_hold,
                "return_order": value.return_order,
              };
              await shoppingCartModelService
                  .createAPIShoppingCartModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getShoppingCartList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "shopping_cart_pk": value.id,
                "subtotal": value.subtotal,
                "cart_purchase_price_total": value.cart_purchase_price_total,
                "total_discount": value.total_discount,
                "cart_item_quantity": value.cart_item_quantity,
                "timestamp": value.timestamp,
                "checked_out": value.checked_out,
                "on_hold": value.on_hold,
              };
              await shoppingCartModelService
                  .createAPIShoppingCartModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('shoppingCart', null, 'Add');

    return true;
  }

  //################### ShoppingCartProductModel

  final ShoppingCartProductModelService shoppingCartProductModelService =
      new ShoppingCartProductModelService();
  Future<bool> postOnShoppingCartProduct(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'shoppingCartProduct', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getShoppingCartProductMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "shopping_cart_product_pk": value.id,
                "product_quantity": value.product_quantity,
                "product_subtotal": value.product_subtotal,
                "product_discount": value.product_discount,
                "product_purchase_price_total": value.product_purchase_price_total,
                "has_variant_option": value.has_variant_option,
                "product_id": value.product_id,
                "shopping_cart_id": value.shopping_cart_id,
              };
              await shoppingCartProductModelService
                  .createAPIShoppingCartProductModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getShoppingCartProductList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "shopping_cart_product_pk": value.id,
                "product_quantity": value.product_quantity,
                "product_subtotal": value.product_subtotal,
                "product_discount": value.product_discount,
                "product_purchase_price_total": value.product_purchase_price_total,
                "has_variant_option": value.has_variant_option,
                "product_id": value.product_id,
                "shopping_cart_id": value.shopping_cart_id,
              };
              await shoppingCartProductModelService
                  .createAPIShoppingCartProductModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('shoppingCartProduct', null, 'Add');

    return true;
  }

  //################### SessionModel

  final SessionModelService sessionModelService = new SessionModelService();
  Future<bool> postOnSession(String token) async {
    // UPDATE
    await dbmanager.getEditedSession("Session", "Edit").then((value) {
      if (value != null) {
        value.forEach((elemnent) async {
          var mapData = {
            "session_pk": elemnent.id,
            "opening_balance": elemnent.opening_balance,
            "opening_time": elemnent.opening_time,
            "session_comment": elemnent.session_comment,
            "closing_time":
                elemnent.closing_time == null ? DateTime.now().toString() : elemnent.closing_time,
            "close_status": elemnent.close_status,
            "drawer_status": elemnent.drawer_status,
          };
          await sessionModelService
              .updateAPISession(mapData, mapData['session_pk'], token)
              .then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Session', 'Edit');
    });

    // Add
    await dbmanager.getHistoryByOperation('Add', 'session', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getSessionMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "session_pk": value.id,
                "opening_balance": value.opening_balance,
                "opening_time": value.opening_time,
                "session_comment": value.session_comment,
                "closing_time":
                    value.closing_time == null ? DateTime.now().toString() : value.closing_time,
                "close_status": value.close_status,
                "drawer_status": value.drawer_status,
              };
              await sessionModelService.createAPISessionModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getSessionAllList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "session_pk": value.id,
                "opening_balance": value.opening_balance,
                "opening_time": value.opening_time,
                "session_comment": value.session_comment,
                "closing_time":
                    value.closing_time == null ? DateTime.now().toString() : value.closing_time,
                "close_status": value.close_status,
                "drawer_status": value.drawer_status,
              };
              await sessionModelService.createAPISessionModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('session', null, 'Add');

    return true;
  }

  //################### OrderModel

  final OrderModelService orderModelService = new OrderModelService();
  Future<bool> postOnOrder(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'posOrder', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getOrderMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "pos_order_pk": value.id,
                "order_subtotal": value.order_subtotal,
                "order_purchase_price_total": value.order_purchase_price_total,
                "order_discount": value.order_discount,
                "cash_collected": value.cash_collected,
                "change_due": value.change_due,
                "order_item_no": value.order_item_no,
                "timestamp": value.timestamp,
                "qr_code_string": value.qr_code_string,
                "payment_completion_status": value.payment_completion_status,
                "cart_id": value.cart_id,
                "session_id": value.session_id,
              };
              await orderModelService.createAPIOrderModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getOrderListAll().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "pos_order_pk": value.id,
                "order_subtotal": value.order_subtotal,
                "order_purchase_price_total": value.order_purchase_price_total,
                "order_discount": value.order_discount,
                "cash_collected": value.cash_collected,
                "change_due": value.change_due,
                "order_item_no": value.order_item_no,
                "timestamp": value.timestamp,
                "qr_code_string": value.qr_code_string,
                "payment_completion_status": value.payment_completion_status,
                "cart_id": value.cart_id,
                "session_id": value.session_id,
              };
              await orderModelService.createAPIOrderModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('posOrder', null, 'Add');

    return true;
  }

  //################### ExpenseModel

  final ExpenseModelService expenseModelService = new ExpenseModelService();
  Future<bool> postOnExpense(String token) async {
    // DELELE
    await dbmanager.getAllBackupHistory("Expense", "Delete").then((value) {
      if (value != null) {
        value.forEach((element) async {
          await expenseModelService.deleteAPIExpense(element.model_id, token).then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Expense', 'Delete');
    });

    // UPDATE
    await dbmanager.getEditedExpense("Expense", "Edit").then((value) {
      if (value != null) {
        value.forEach((elemnent) async {
          var mapData = {
            "expense_pk": elemnent.id,
            "expense_type": elemnent.expense_type,
            "reason": elemnent.reason,
            "amount": elemnent.amount,
            "timestamp": elemnent.timestamp,
            "session_id": elemnent.session_id,
          };
          await expenseModelService
              .updateAPIExpense(mapData, mapData['expense_pk'], token)
              .then((onValue) {
            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Expense', 'Edit');
    });

    // Add
    await dbmanager.getHistoryByOperation('Add', 'expense', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getExpenseMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "expense_pk": value.id,
                "expense_type": value.expense_type,
                "reason": value.reason,
                "amount": value.amount,
                "timestamp": value.timestamp,
                "session_id": value.session_id,
              };
              await expenseModelService.createAPIExpenseModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getExpenseAllList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "expense_pk": value.id,
                "expense_type": value.expense_type,
                "reason": value.reason,
                "amount": value.amount,
                "timestamp": value.timestamp,
                "session_id": value.session_id,
              };
              await expenseModelService.createAPIExpenseModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('expense', null, 'Add');

    return true;
  }

  //################### SelectedProductVariantModel

  Future<bool> postOnSelectedProductVariant(String token) async {
    // Add
    await dbmanager
        .getHistoryByOperation('Add', 'selectedProductVariant', null)
        .then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getSelectedProductVariantMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "selected_product_variant_pk": value.id,
                "option_name": value.option_name,
                "price": value.price,
                "product_variant_option_id": value.product_variant_option_id,
                "option_id": value.option_id,
                "variant_id": value.variant_id,
                "product_id": value.product_id,
                "shopping_cart_id": value.shopping_cart_id,
                "shopping_cart_product_id": value.shopping_cart_product_id,
              };
              await selectedProductVariantModelService
                  .createAPISelectedProductVariantModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getSelectedProductVariantList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "selected_product_variant_pk": value.id,
                "option_name": value.option_name,
                "price": value.price,
                "product_variant_option_id": value.product_variant_option_id,
                "option_id": value.option_id,
                "variant_id": value.variant_id,
                "product_id": value.product_id,
                "shopping_cart_id": value.shopping_cart_id,
                "shopping_cart_product_id": value.shopping_cart_product_id,
              };
              await selectedProductVariantModelService
                  .createAPISelectedProductVariantModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('selectedProductVariant', null, 'Add');

    return true;
  }

  //################### BarcodeModel

  Future<bool> postOnBarcode(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'barcode', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getBarcodeMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "barcode_pk": value.id,
                "name": value.name,
                "product_id": value.product_id,
                "barcode_text": value.barcode_text,
              };
              await barcodeModelService.createAPIBarcodeModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getBarcodeList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "barcode_pk": value.id,
                "name": value.name,
                "product_id": value.product_id,
                "barcode_text": value.barcode_text,
              };
              await barcodeModelService.createAPIBarcodeModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('barcode', null, 'Add');

    return true;
  }

  //################### allLogs

  final LogsModelService logsModelService = new LogsModelService();
  Future<bool> postOnLogs(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'allLogs', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getLogMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "log_pk": value.id,
                "operation": value.operation,
                "detail": value.detail,
                "model_id": value.model_id,
                "model": value.model,
                "timestamp": value.timestamp,
              };
              await logsModelService.createAPILogs(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getAllLogs().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "log_pk": value.id,
                "operation": value.operation,
                "detail": value.detail,
                "model_id": value.model_id,
                "model": value.model,
                "timestamp": value.timestamp,
              };
              await logsModelService.createAPILogs(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('allLogs', null, 'Add');

    return true;
  }

  //################### ProductLog

  final ProductLogModelService productLogModelService = new ProductLogModelService();
  Future<bool> postOnProductLog(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'productLog', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getProductLogMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "product_log_pk": value.id,
                "name": value.name,
                "purchase": value.purchase,
                "price": value.price,
                "barcode": value.barcode,
                "enable_product": value.enable_product,
                "quantity": value.quantity,
                "weight": value.weight,
                "all_log_id": value.all_log_id,
                "has_variant": value.has_variant,
              };
              await productLogModelService.createAPIProductLog(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getProductLogList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "product_log_pk": value.id,
                "name": value.name,
                "purchase": value.purchase,
                "price": value.price,
                "barcode": value.barcode,
                "enable_product": value.enable_product,
                "quantity": value.quantity,
                "weight": value.weight,
                "all_log_id": value.all_log_id,
                "has_variant": value.has_variant,
              };
              await productLogModelService.createAPIProductLog(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('productLog', null, 'Add');

    return true;
  }

  //################### InvoiceModel

  final InvoiceModelService invoiceModelService = new InvoiceModelService();
  Future<bool> postOnInvoice(String token) async {
    // UPDATE
    await dbmanager.getEditedInvoice("Invoice", "Edit").then((objectList) {
      if (objectList != null) {
        objectList.forEach((value) async {
          var mapData = {
            "invoice_pk": value.id,
            "invoice_subtotal": value.invoice_subtotal,
            "invoice_discount": value.invoice_discount,
            "invoice_paid_amount": value.invoice_paid_amount,
            "invoice_payable_amount": value.invoice_payable_amount,
            "invoice_item_no": value.invoice_item_no,
            "customer_name": value.customer_name,
            "customer_address": value.customer_address,
            "customer_phone": value.customer_phone,
            "customer_email": value.customer_email,
            "qr_code_string": value.qr_code_string,
            "invoice_number": value.invoice_number,
            "invoice_issue_date": value.invoice_issue_date,
            "invoice_due_date": value.invoice_due_date,
            "invoice_paid_status": value.invoice_paid_status,
            "cart_id": value.cart_id,
            "session_id": value.session_id,
            "order_id": value.order_id,
          };
          await invoiceModelService
              .updateAPIInvoice(mapData, mapData['invoice_pk'], token)
              .then((onValue) async {
            // UPDATE
            await dbmanager.getSingleOrder(value.order_id).then((orderObject) async {
              if (orderObject != null) {
                var mapData1 = {
                  "pos_order_pk": orderObject.id,
                  "order_subtotal": orderObject.order_subtotal,
                  "order_purchase_price_total": orderObject.order_purchase_price_total,
                  "order_discount": orderObject.order_discount,
                  "cash_collected": orderObject.cash_collected,
                  "change_due": orderObject.change_due,
                  "order_item_no": orderObject.order_item_no,
                  "timestamp": orderObject.timestamp,
                  "payment_completion_status": orderObject.payment_completion_status,
                };
                await orderModelService
                    .updateAPIOrder(mapData1, mapData1['pos_order_pk'], token)
                    .then((onValue) {
                  if (onValue.error) {
                    tableErrors.add(onValue.errorMessage);
                  }
                });
              }
            });

            if (onValue.error) {
              tableErrors.add(onValue.errorMessage);
            }
          });
        });
      }
      logActivity.deleteBackupPartially('Invoice', 'Edit');
    });

    // Add
    await dbmanager.getHistoryByOperation('Add', 'invoice', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getInvoiceMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "invoice_pk": value.id,
                "invoice_subtotal": value.invoice_subtotal,
                "invoice_discount": value.invoice_discount,
                "invoice_paid_amount": value.invoice_paid_amount,
                "invoice_payable_amount": value.invoice_payable_amount,
                "invoice_item_no": value.invoice_item_no,
                "customer_name": value.customer_name,
                "customer_address": value.customer_address,
                "customer_phone": value.customer_phone,
                "customer_email": value.customer_email,
                "qr_code_string": value.qr_code_string,
                "invoice_number": value.invoice_number,
                "invoice_issue_date": value.invoice_issue_date,
                "invoice_due_date": value.invoice_due_date,
                "invoice_paid_status": value.invoice_paid_status,
                "cart_id": value.cart_id,
                "session_id": value.session_id,
                "order_id": value.order_id,
              };
              await invoiceModelService.createAPIInvoiceModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getInvoiceListAll().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "invoice_pk": value.id,
                "invoice_subtotal": value.invoice_subtotal,
                "invoice_discount": value.invoice_discount,
                "invoice_paid_amount": value.invoice_paid_amount,
                "invoice_payable_amount": value.invoice_payable_amount,
                "invoice_item_no": value.invoice_item_no,
                "customer_name": value.customer_name,
                "customer_address": value.customer_address,
                "customer_phone": value.customer_phone,
                "customer_email": value.customer_email,
                "qr_code_string": value.qr_code_string,
                "invoice_number": value.invoice_number,
                "invoice_issue_date": value.invoice_issue_date,
                "invoice_due_date": value.invoice_due_date,
                "invoice_paid_status": value.invoice_paid_status,
                "cart_id": value.cart_id,
                "session_id": value.session_id,
                "order_id": value.order_id,
              };
              await invoiceModelService.createAPIInvoiceModel(mapData, token).then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('invoice', null, 'Add');

    return true;
  }

  //################### NotificationModel

  final NotificationModelService notificationModelService = new NotificationModelService();
  Future<List<String>> postOnNotification(String token) async {
    // Add
    await dbmanager.getHistoryByOperation('Add', 'notification', null).then((modelId) async {
      if (modelId != null && modelId.model_id != null) {
        await dbmanager.getNoteMax(modelId.model_id).then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "notification_pk": value.id,
                "subject": value.subject,
                "timestamp": value.timestamp,
                "detail_id": value.detail_id,
                "note_type": value.note_type,
                "seen_status": value.seen_status,
              };
              await notificationModelService
                  .createAPINotificationModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      } else {
        await dbmanager.getNotificationList().then((objectList) {
          if (objectList != null) {
            objectList.forEach((value) async {
              var mapData = {
                "notification_pk": value.id,
                "subject": value.subject,
                "timestamp": value.timestamp,
                "detail_id": value.detail_id,
                "note_type": value.note_type,
                "seen_status": value.seen_status,
              };
              await notificationModelService
                  .createAPINotificationModel(mapData, token)
                  .then((onValue) {
                if (onValue.error) {
                  tableErrors.add(onValue.errorMessage);
                }
              });
            });
          }
        });
      }
    });

    logActivity.recordBackupHistory('notification', null, 'Add');

    return tableErrors;
  }
}
