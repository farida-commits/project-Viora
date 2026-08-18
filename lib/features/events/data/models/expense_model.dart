// lib/features/events/data/models/expense_model.dart

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
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final DateTime? date;

  Expense toEntity() => Expense(id: id, title: title, price: price, date: date);

  factory ExpenseModel.fromEntity(Expense e) => ExpenseModel(
        id: e.id,
        title: e.title,
        price: e.price,
        date: e.date,
      );
}