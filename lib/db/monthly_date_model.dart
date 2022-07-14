class MonthlyDateModel {
  String year;
  double revenue;
  double expense;
  double profit;

  MonthlyDateModel({
    this.year,
    this.revenue,
    this.expense,
    this.profit,
  });

  Map<String, dynamic> toMap() {
    return {'year': year, 'revenue': revenue, 'expense': expense, 'profit': profit};
  }

  MonthlyDateModel.fromDb(Map map)
      : year = map["year"],
        revenue = map["revenue"],
        expense = map["expense"],
        profit = map["profit"];
}
