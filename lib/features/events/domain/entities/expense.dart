class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.price,
    required this.date,
  });

  final String id;
  final String title;
  final double price;
  final DateTime? date;

  Expense copyWith({String? title, double? price, DateTime? date}) {
    return Expense(
      id: id,
      title: title ?? this.title,
      price: price ?? this.price,
      date: date ?? this.date,
    );
  }
}