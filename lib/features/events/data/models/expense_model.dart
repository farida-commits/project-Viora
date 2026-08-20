import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 2)
class ExpenseModel extends HiveObject {
  ExpenseModel({
    required this.id,
    required this.title,
    required this.price,
    this.date,
  });

  @HiveField(0)
  String id;  // Убрали final

  @HiveField(1)
  String title;  // Убрали final

  @HiveField(2)
  double price;  // Убрали final

  @HiveField(3)
  DateTime? date;  // Убрали final

  Expense toEntity() => Expense(id: id, title: title, price: price, date: date);

  factory ExpenseModel.fromEntity(Expense e) => ExpenseModel(
        id: e.id,
        title: e.title,
        price: e.price,
        date: e.date,
      );
}