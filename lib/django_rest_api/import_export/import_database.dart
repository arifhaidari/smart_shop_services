import 'package:pos/db/barcode_model.dart';
import 'package:pos/db/category_model.dart';
import 'package:pos/db/category_product_model.dart';

//My Imports
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/expense_model.dart';
import 'package:pos/db/invoice_model.dart';
import 'package:pos/db/logs/all_logs.dart';
import 'package:pos/db/logs/product_log.dart';
import 'package:pos/db/notification_model.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/db/product_variant_option.dart';
import 'package:pos/db/selected_product_variant.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/db/shopping_cart_model.dart';
import 'package:pos/db/shopping_product_model.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/db/variant_option_model.dart';
import 'package:pos/db/variant_product_model.dart';
import 'package:pos/django_rest_api/api_response.dart';
import 'package:pos/django_rest_api/import_export/import_messages.dart';
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

class ImportDatabase {
  final PosDatabase dbmanager = new PosDatabase();

  bool isLoading = false;

  /////////////###### Import Starts

  //################### Cateogry starts

  final CategoryService categoryService = new CategoryService();
  APIResponse<List<Category>> apiCategoryListResponse;

  Future<APIResponse<ImportMessages>> listOfCategory(String token) async {
    isLoading = true;
    apiCategoryListResponse = await categoryService.getAPICategoryList(token);

    isLoading = false;

    if (apiCategoryListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiCategoryListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiCategoryListResponse.data.length != 0) {
        apiCategoryListResponse.data.forEach((value) async {
          Category categoryObject = Category(
            id: value.id,
            name: value.name,
            include_in_drawer: value.include_in_drawer,
          );
          await dbmanager.importCategory(categoryObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ Varaint Starts

  final VariantService variantService = new VariantService();
  APIResponse<List<Variant>> apiVariantListResponse;

  Future<APIResponse<ImportMessages>> listOfVariant(String token) async {
    isLoading = true;
    apiVariantListResponse = await variantService.getAPIVariantList(token);

    isLoading = false;

    if (apiVariantListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiVariantListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiVariantListResponse.data.length != 0) {
        apiVariantListResponse.data.forEach((value) async {
          Variant variantObject = Variant(
            id: value.id,
            name: value.name,
          );
          await dbmanager.importVariant(variantObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ VaraintOption Starts

  final VariantOptionService variantOptionService = new VariantOptionService();
  APIResponse<List<VariantOption>> apiVariantOptionListResponse;

  Future<APIResponse<ImportMessages>> listOfVariantOption(String token) async {
    isLoading = true;
    apiVariantOptionListResponse = await variantOptionService.getAPIVariantOptionList(token);

    isLoading = false;

    if (apiVariantOptionListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiVariantOptionListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiVariantOptionListResponse.data.length != 0) {
        apiVariantOptionListResponse.data.forEach((value) async {
          VariantOption variantOptionObject = VariantOption(
            id: value.id,
            option_name: value.option_name,
            variant_id: value.variant_id,
          );
          await dbmanager.importVariantOption(variantOptionObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ Product Starts

  final ProductService productService = new ProductService();
  APIResponse<List<Product>> apiProductListResponse;

  Future<APIResponse<ImportMessages>> listOfProduct(String token) async {
    isLoading = true;
    apiProductListResponse = await productService.getAPIProductList(token);

    isLoading = false;

    if (apiProductListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiProductListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiProductListResponse.data.length != 0) {
        apiProductListResponse.data.forEach((value) async {
          Product productObject = Product(
            id: value.id,
            name: value.name,
            alias: value.alias,
            purchase: value.purchase,
            price: value.price,
            picture: value.picture,
            barcode: value.barcode,
            enable_product: value.enable_product,
            quantity: value.quantity,
            weight: value.weight,
            has_variant: value.has_variant,
          );
          await dbmanager.importProduct(productObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ CategoryProduct Starts

  final CategoryProductJoinService categoryProductService = new CategoryProductJoinService();
  APIResponse<List<CategoryProductJoin>> apiCategoryProductListResponse;

  Future<APIResponse<ImportMessages>> listOfCategoryProductJoin(String token) async {
    isLoading = true;
    apiCategoryProductListResponse =
        await categoryProductService.getAPICategoryProductJoinList(token);

    isLoading = false;

    if (apiCategoryProductListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiCategoryProductListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiCategoryProductListResponse.data.length != 0) {
        apiCategoryProductListResponse.data.forEach((value) async {
          CategoryProductJoin categoryProductObject = CategoryProductJoin(
            id: value.id,
            category_id: value.category_id,
            product_id: value.product_id,
          );
          await dbmanager.importCategoryProduct(categoryProductObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ VariantProductJoin Starts

  final VariantProductJoinService variantProductJoinService = new VariantProductJoinService();
  APIResponse<List<VariantProductJoin>> apiVariantProductListResponse;

  Future<APIResponse<ImportMessages>> listOfVariantProductJoin(String token) async {
    isLoading = true;
    apiVariantProductListResponse =
        await variantProductJoinService.getAPIVariantProductJoinList(token);

    isLoading = false;

    if (apiVariantProductListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiVariantProductListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiVariantProductListResponse.data.length != 0) {
        apiVariantProductListResponse.data.forEach((value) async {
          VariantProductJoin variantProductObject = VariantProductJoin(
            id: value.id,
            variant_id: value.variant_id,
            product_id: value.product_id,
          );
          await dbmanager.importVariantProduct(variantProductObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ ProductVaraintOption Starts

  final ProductVariantOptionService productVariantOptionService = new ProductVariantOptionService();
  APIResponse<List<ProductVariantOption>> apiProductVariantOptionListResponse;

  Future<APIResponse<ImportMessages>> listOfProductVariantOption(String token) async {
    isLoading = true;
    apiProductVariantOptionListResponse =
        await productVariantOptionService.getAPIProductVariantOptionList(token);

    isLoading = false;

    if (apiProductVariantOptionListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiProductVariantOptionListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiProductVariantOptionListResponse.data.length != 0) {
        apiProductVariantOptionListResponse.data.forEach((value) async {
          ProductVariantOption productVariantOptionObject = ProductVariantOption(
            id: value.id,
            product_id: value.product_id,
            variant_id: value.variant_id,
            option_id: value.option_id,
            price: value.price,
          );
          await dbmanager.importProdcutVariantOption(productVariantOptionObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ ProductVaraintOption Starts

  final ShoppingCartModelService shoppingCartModelService = new ShoppingCartModelService();
  APIResponse<List<ShoppingCartModel>> apiShoppingCartListResponse;

  Future<APIResponse<ImportMessages>> listOfShoppingCart(String token) async {
    isLoading = true;
    apiShoppingCartListResponse = await shoppingCartModelService.getAPIShoppingCartModelList(token);

    isLoading = false;

    if (apiShoppingCartListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiShoppingCartListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiShoppingCartListResponse.data.length != 0) {
        apiShoppingCartListResponse.data.forEach((value) async {
          ShoppingCartModel shoppingCartObject = ShoppingCartModel(
            id: value.id,
            subtotal: value.subtotal,
            cart_purchase_price_total: value.cart_purchase_price_total,
            total_discount: value.total_discount,
            cart_item_quantity: value.cart_item_quantity,
            timestamp: value.timestamp.toString(),
            checked_out: value.checked_out,
            on_hold: value.on_hold,
            return_order: value.return_order,
          );
          await dbmanager.importShoppingCartCart(shoppingCartObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ shoppingCartProductModel Starts

  final ShoppingCartProductModelService shoppingCartProductModelService =
      new ShoppingCartProductModelService();
  APIResponse<List<ShoppingCartProductModel>> apiShoppingCartProductListResponse;

  Future<APIResponse<ImportMessages>> listOfShoppingCartProduct(String token) async {
    isLoading = true;
    apiShoppingCartProductListResponse =
        await shoppingCartProductModelService.getAPIShoppingCartProductModelList(token);

    isLoading = false;

    if (apiShoppingCartProductListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiShoppingCartProductListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiShoppingCartProductListResponse.data.length != 0) {
        apiShoppingCartProductListResponse.data.forEach((value) async {
          ShoppingCartProductModel apiShoppingCartProductObject = ShoppingCartProductModel(
            id: value.id,
            product_quantity: value.product_quantity,
            product_subtotal: value.product_subtotal,
            product_discount: value.product_discount,
            product_purchase_price_total: value.product_purchase_price_total,
            has_variant_option: value.has_variant_option,
            product_id: value.product_id,
            shopping_cart_id: value.shopping_cart_id,
          );
          await dbmanager.importShoppingCartProduct(apiShoppingCartProductObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ SessionModel Starts

  final SessionModelService sessionModelService = new SessionModelService();
  APIResponse<List<SessionModel>> apiSessionListResponse;

  Future<APIResponse<ImportMessages>> listOfSession(String token) async {
    isLoading = true;
    apiSessionListResponse = await sessionModelService.getAPISessionModelList(token);

    isLoading = false;

    if (apiSessionListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiSessionListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiSessionListResponse.data.length != 0) {
        apiSessionListResponse.data.forEach((value) async {
          SessionModel sessionObject = SessionModel(
            id: value.id,
            opening_balance: value.opening_balance,
            opening_time: value.opening_time.toString(),
            closing_time: value.closing_time.toString(),
            session_comment: value.session_comment,
            close_status: value.close_status,
            drawer_status: value.drawer_status,
          );
          await dbmanager.importSession(sessionObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ OrderModel Starts

  final OrderModelService orderModelService = new OrderModelService();
  APIResponse<List<OrderModel>> apiOrderModelListResponse;

  Future<APIResponse<ImportMessages>> listOfOrder(String token) async {
    isLoading = true;
    apiOrderModelListResponse = await orderModelService.getAPIOrderModelList(token);

    isLoading = false;

    if (apiOrderModelListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiOrderModelListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiOrderModelListResponse.data.length != 0) {
        apiOrderModelListResponse.data.forEach((value) async {
          OrderModel orderObject = OrderModel(
            id: value.id,
            order_subtotal: value.order_subtotal,
            order_purchase_price_total: value.order_purchase_price_total,
            order_discount: value.order_discount,
            cash_collected: value.cash_collected,
            change_due: value.change_due,
            order_item_no: value.order_item_no,
            timestamp: value.timestamp.toString(),
            qr_code_string: value.qr_code_string,
            payment_completion_status: value.payment_completion_status,
            cart_id: value.cart_id,
            session_id: value.session_id,
          );
          await dbmanager.importOrder(orderObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ expenseModel Starts

  final ExpenseModelService expenseModelService = new ExpenseModelService();
  APIResponse<List<ExpenseModel>> apiExpenseModelListResponse;

  Future<APIResponse<ImportMessages>> listOfExpense(String token) async {
    isLoading = true;
    apiExpenseModelListResponse = await expenseModelService.getAPIExpenseModelList(token);

    isLoading = false;

    if (apiExpenseModelListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiExpenseModelListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiExpenseModelListResponse.data.length != 0) {
        apiExpenseModelListResponse.data.forEach((value) async {
          ExpenseModel expenseModelObject = ExpenseModel(
            id: value.id,
            expense_type: value.expense_type,
            reason: value.reason,
            amount: value.amount,
            timestamp: value.timestamp.toString(),
            session_id: value.session_id,
          );
          await dbmanager.importExpense(expenseModelObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ SelectedProductVariantModel Starts

  final SelectedProductVariantModelService selectedProductVariantModelService =
      new SelectedProductVariantModelService();
  APIResponse<List<SelectedProductVariantModel>> apiSelectedProductVariantListResponse;

  Future<APIResponse<ImportMessages>> listOfSelectedProductVariantModel(String token) async {
    isLoading = true;
    apiSelectedProductVariantListResponse =
        await selectedProductVariantModelService.getAPISelectedProductVariantModelList(token);

    isLoading = false;

    if (apiSelectedProductVariantListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiSelectedProductVariantListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiSelectedProductVariantListResponse.data.length != 0) {
        apiSelectedProductVariantListResponse.data.forEach((value) async {
          SelectedProductVariantModel selectedProductVariantModelObject =
              SelectedProductVariantModel(
            id: value.id,
            option_name: value.option_name,
            price: value.price,
            product_variant_option_id: value.product_variant_option_id,
            option_id: value.option_id,
            variant_id: value.variant_id,
            product_id: value.product_id,
            shopping_cart_id: value.shopping_cart_id,
            shopping_cart_product_id: value.shopping_cart_product_id,
          );
          await dbmanager.importSelectedProductVariant(selectedProductVariantModelObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ BarcodeModel Starts

  final BarcodeModelService barcodeModelService = new BarcodeModelService();
  APIResponse<List<BarcodeModel>> apiBarcodeModelListResponse;

  Future<APIResponse<ImportMessages>> listOfBarcodeModel(String token) async {
    isLoading = true;
    apiBarcodeModelListResponse = await barcodeModelService.getAPIBarcodeModelList(token);

    isLoading = false;

    if (apiBarcodeModelListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiBarcodeModelListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiBarcodeModelListResponse.data.length != 0) {
        apiBarcodeModelListResponse.data.forEach((value) async {
          BarcodeModel barcodeModelObject = BarcodeModel(
            id: value.id,
            name: value.name,
            barcode_text: value.barcode_text,
          );
          await dbmanager.importBarcode(barcodeModelObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ Logs Starts

  final LogsModelService logsModelService = new LogsModelService();
  APIResponse<List<Logs>> apiLogsListResponse;

  Future<APIResponse<ImportMessages>> listOfLogs(String token) async {
    isLoading = true;
    apiLogsListResponse = await logsModelService.getAPILogsList(token);

    isLoading = false;

    if (apiLogsListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiLogsListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiLogsListResponse.data.length != 0) {
        apiLogsListResponse.data.forEach((value) async {
          Logs logObject = Logs(
            id: value.id,
            operation: value.operation,
            detail: value.detail,
            model_id: value.model_id,
            model: value.model,
            timestamp: value.timestamp,
          );
          await dbmanager.importAllLogs(logObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ BarcodeModel Starts

  final ProductLogModelService productLogModelService = new ProductLogModelService();
  APIResponse<List<ProductLog>> apiProductLogListResponse;

  Future<APIResponse<ImportMessages>> listOfProductLog(String token) async {
    isLoading = true;
    apiProductLogListResponse = await productLogModelService.getAPIProductLogList(token);

    isLoading = false;

    if (apiProductLogListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiProductLogListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiProductLogListResponse.data.length != 0) {
        apiProductLogListResponse.data.forEach((value) async {
          ProductLog productLog = ProductLog(
              id: value.id,
              name: value.name,
              purchase: value.purchase,
              price: value.price,
              barcode: value.barcode,
              enable_product: value.enable_product,
              quantity: value.quantity,
              weight: value.weight,
              all_log_id: value.all_log_id,
              has_variant: value.has_variant);
          await dbmanager.importProductLog(productLog);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  //############################ InvoiceModel Starts

  final InvoiceModelService invoiceModelService = new InvoiceModelService();
  APIResponse<List<InvoiceModel>> apiInvoiceModelListResponse;

  Future<APIResponse<ImportMessages>> listOfInvoiceModel(String token) async {
    isLoading = true;
    apiInvoiceModelListResponse = await invoiceModelService.getAPIInvoiceModelList(token);

    isLoading = false;

    if (apiInvoiceModelListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiInvoiceModelListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiInvoiceModelListResponse.data.length != 0) {
        apiInvoiceModelListResponse.data.forEach((value) async {
          InvoiceModel invoiceModelObject = InvoiceModel(
            id: value.id,
            invoice_subtotal: value.invoice_subtotal,
            invoice_discount: value.invoice_discount,
            invoice_paid_amount: value.invoice_paid_amount,
            invoice_payable_amount: value.invoice_payable_amount,
            invoice_item_no: value.invoice_item_no,
            customer_name: value.customer_name,
            customer_address: value.customer_address,
            customer_phone: value.customer_phone,
            customer_email: value.customer_email,
            qr_code_string: value.qr_code_string,
            invoice_number: value.invoice_number,
            invoice_issue_date: value.invoice_issue_date,
            invoice_due_date: value.invoice_due_date,
            invoice_paid_status: value.invoice_paid_status,
            cart_id: value.cart_id,
            session_id: value.session_id,
            order_id: value.order_id,
          );
          await dbmanager.importInvoice(invoiceModelObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

  final NotificationModelService notificationModelService = new NotificationModelService();
  APIResponse<List<NotificationModel>> apiNotificationModelListResponse;

  Future<APIResponse<ImportMessages>> listOfNotificationModel(String token) async {
    isLoading = true;
    apiNotificationModelListResponse =
        await notificationModelService.getAPINotificationModelList(token);

    isLoading = false;

    if (apiNotificationModelListResponse.error) {
      ImportMessages importMessages =
          ImportMessages(error: true, message: apiNotificationModelListResponse.errorMessage);
      return APIResponse<ImportMessages>(data: importMessages);
    } else if (isLoading == false) {
      if (apiNotificationModelListResponse.data.length != 0) {
        apiNotificationModelListResponse.data.forEach((value) async {
          NotificationModel notificationModelObject = NotificationModel(
            id: value.id,
            subject: value.subject,
            timestamp: value.timestamp.toString(),
            detail_id: value.detail_id,
            note_type: value.note_type,
            seen_status: value.seen_status,
          );
          await dbmanager.importNotification(notificationModelObject);
        });
      }
    }
    ImportMessages importMessages = ImportMessages(error: false, message: "");
    return APIResponse<ImportMessages>(data: importMessages);
  }

///////////// Import ends

}
