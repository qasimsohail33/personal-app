import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transactions.dart';

class DatabaseService {
  // We no longer need to pass the userId explicitly, we fetch it from FirebaseAuth
  final String? userId;

  DatabaseService({this.userId});

  // Collection reference for transactions in Firestore
  final CollectionReference transactionCollection =
  FirebaseFirestore.instance.collection('transactions');

  // Add a new transaction
  Future<void> addTransaction(FinanceTransaction transaction) async {
    // Ensure the user is logged in
    if (userId != null) {
      try {
        await transactionCollection.add({
          'title': transaction.title,
          'amount': transaction.amount,
          'type': transaction.type,
          'category': transaction.category,
          'date': transaction.date,
          'userId': userId, // Store the user ID with the transaction
        });
      } catch (e) {
        print("Error adding transaction: $e");
      }
    } else {
      print("No user is logged in.");
    }
  }

  // Get a stream of transactions for the logged-in user
  Stream<List<FinanceTransaction>> getTransactions() {
    // Ensure the user is logged in before fetching data
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      print("User is not logged in.");
      return Stream.empty();
    }

    // Fetch transactions for the current logged-in user
    return transactionCollection
        .where('userId', isEqualTo: currentUserId) // Filter by user ID
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FinanceTransaction(
          id: doc.id,
          title: doc['title'],
          amount: doc['amount'],
          type: doc['type'],
          category: doc['category'],
          date: (doc['date'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }
}
