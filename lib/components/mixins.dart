import 'dart:math';

import 'package:pos/db/app_language.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/session_model.dart';

final BASE_ENDPOINT = "https://smartshop.services/api/";
// final BASE_ENDPOINT = "http://192.168.0.136:8000/api/";

final PosDatabase dbmanager = new PosDatabase();

void sessionEnder(SessionModel sessionModelObject) async {
  // Current Session
  double sessionDailyExpense = 0.0;
  double sessionClosingBalance = 0.0;
  double totalSessionClosingAmount = 0.0;
  await dbmanager.getSessionDailyExpense(sessionModelObject.id, "daily").then((dailyExpense) {
    if (dailyExpense != null) {
      sessionDailyExpense = dailyExpense;
    }
  });

  await dbmanager.getSessionOrderSubtotal(sessionModelObject.id).then((orderSubtotalSum) {
    if (orderSubtotalSum != null) {
      sessionClosingBalance = orderSubtotalSum - sessionDailyExpense;
    }
  });

  totalSessionClosingAmount = sessionModelObject.opening_balance + sessionClosingBalance;

  // Previous Session
  double sessionDailyExpensePrevious = 0.0;
  double sessionClosingBalancePrevious = 0.0;
  double totalSessionClosingAmountPrevious = 0.0;
  double openingBalancePrevious = 0.0;
  double theResult = 0.0;

  await dbmanager.getPreviousSession().then((valuePrevious) async {
    if (valuePrevious != null) {
      openingBalancePrevious = valuePrevious.opening_balance;
      await dbmanager.getSessionDailyExpense(valuePrevious.id, "daily").then((dailyExpense) {
        if (dailyExpense != null) {
          sessionDailyExpensePrevious = dailyExpense;
        }
      });

      await dbmanager.getSessionOrderSubtotal(valuePrevious.id).then((orderSubtotalSum) {
        if (orderSubtotalSum != null) {
          sessionClosingBalancePrevious = orderSubtotalSum - sessionDailyExpensePrevious;
        }
      });
    } else {}
  });

  totalSessionClosingAmountPrevious = openingBalancePrevious + sessionClosingBalancePrevious;

  theResult = totalSessionClosingAmount - totalSessionClosingAmountPrevious;

  sessionModelObject.closing_time = DateTime.now().toString();
  sessionModelObject.close_status = true;
  //
  if (theResult > 0) {
    sessionModelObject.drawer_status = true;
  } else {
    sessionModelObject.drawer_status = false;
  }

  await dbmanager.updateSession(sessionModelObject).then((id) {});
}

List<AppLanguage> languages = [
  AppLanguage(language_code: "en", country_code: "US", active: true),
  AppLanguage(language_code: "fa", country_code: "IR", active: false),
  AppLanguage(language_code: "ps", country_code: "AR", active: false),
];

void createLanguages() async {
  languages.forEach((element) async {
    await dbmanager.createLaguages(element);
  });
}

int _generateRandmomNum() {
  var randomGenerator = Random();

  int randomNumber = randomGenerator.nextInt(1000000) + 100;

  return randomNumber;
}

void rememberMe() async {
  await dbmanager.getSingleUser().then((onValue) async {
    onValue.remember_me = true;
    await dbmanager.updateUser(onValue);
  });
}
