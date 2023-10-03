enum TransactionType {
  income,
  expense,
}

class Transaction {
  double value;
  String name;
  DateTime date;
  TransactionType type;
  String category;

  Transaction({
    required this.value,
    required this.name,
    required this.date,
    required this.type,
    required this.category,
  });

  String get month => date.month.toString();
  String get year => date.year.toString();
}
