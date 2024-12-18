import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  // Convert Firestore document to FinanceTransaction object
  factory FinanceTransaction.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return FinanceTransaction(
      id: doc.id,
      title: data['title'],
      amount: data['amount'],
      type: data['type'],
      category: data['category'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Convert FinanceTransaction object to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
    };
  }
}
