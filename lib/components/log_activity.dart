import 'package:pos/db/bakcup_history/backup_history_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/logs/all_logs.dart';
import 'package:pos/db/logs/log_activation.dart';
import 'package:pos/db/logs/product_log.dart';
import 'package:pos/db/product_model.dart';

class LogAcitvity {
  final PosDatabase dbmanager = new PosDatabase();

  Future<void> createLogActivation(String operation) async {
    if (operation == "active_log") {
      logActivation().then((value) async {
        if (value == null) {
          LogActivation logActivation = LogActivation(log_activate: true, backup_activation: false);
          await dbmanager.createLogActivation(logActivation);
        } else {
          if (!value.log_activate) {
            value.log_activate = true;
            await dbmanager.updateLogActivation(value);
          }
        }
      });
    } else {
      logActivation().then((value) async {
        if (value == null) {
          LogActivation logActivation = LogActivation(log_activate: false, backup_activation: true);
          await dbmanager.createLogActivation(logActivation);
        } else {
          if (!value.backup_activation) {
            value.backup_activation = true;
            await dbmanager.updateLogActivation(value);
          }
        }
      });
    }
  }

  Future<LogActivation> logActivation() async {
    LogActivation tempValue;
    await dbmanager.getLogActivation().then((value) async {
      if (value != null) {
        tempValue = value;
      }
    });
    return tempValue;
  }

  Future<void> recordLog(
      String detail, String operation, int modelId, String model, Product productObject) async {
    Logs logs = Logs(
        operation: operation,
        detail: detail,
        model_id: modelId,
        model: model,
        timestamp: DateTime.now().toString());

    await dbmanager.createLog(logs).then((id) {
      if (operation == 'edit_product' || productObject != null) {
        recordProductEdit(id, modelId, productObject);
      }
    });
  }

  void recordProductEdit(int logId, int productId, Product product) async {
    ProductLog productLog = ProductLog(
      name: product.name,
      purchase: product.purchase,
      price: product.price,
      barcode: product.barcode,
      enable_product: product.enable_product,
      quantity: product.quantity,
      weight: product.weight,
      all_log_id: logId,
      has_variant: product.has_variant,
    );
    await dbmanager.createProductLog(productLog);
  }

  Future<void> recordBackupHistory(String model, int modelId, String operation) async {
    if (operation != "Add") {
      await dbmanager.getHistoryByOperation(operation, model, modelId).then((value) async {
        if (value == null) {
          BackupHistory backupHistory =
              BackupHistory(model: model, model_id: modelId, operation: operation);

          await dbmanager.createBackupHistory(backupHistory);
        }
      });
    } else {
      await dbmanager.getHistoryByOperation(operation, model, null).then((value) async {
        if (value != null) {
          await dbmanager.getMaxId(model).then((theValue) async {
            if (theValue != null) {
              value.model_id = theValue;
              await dbmanager.updateBackupHistory(value);
            }
          });
        } else {
          await dbmanager.getMaxId(model).then((maxId) async {
            BackupHistory backupHistory =
                BackupHistory(model: model, model_id: maxId, operation: operation);

            await dbmanager.createBackupHistory(backupHistory);
          });
        }
      });
    }
  }

  void deleteBackupPartially(String model, String operation) async {
    await dbmanager.deleteBackupUpdationHistory(model, operation);
  }
}
