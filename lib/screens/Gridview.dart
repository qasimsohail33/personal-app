import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_app/screens/LoginScreen.dart';

import '../models/transactions.dart';
import '../serrvices/database_services.dart';

class TransactionGridsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // If no user is logged in, show the login screen
    if (userId == null) {
      return LoginScreen();
    }

    // Initialize the database service only when the user is logged in
    final databaseService = DatabaseService(userId: userId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.credit_card, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Grouped Transactions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Ad Container at the top
          Container(
            height: 150, // Increased height of ad container
            color: Colors.grey[800],
            alignment: Alignment.center,
            child: Text(
              'Ad Space',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Spacer below ad container
          Container(
            height: 50, // Empty container for spacing
            color: Colors.transparent,
          ),
          // Expanded to display transactions
          Expanded(
            child: StreamBuilder<List<FinanceTransaction>>(
              stream: databaseService.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions available',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final transactions = snapshot.data!;

                // Group transactions by category and sort by date
                final groupedTransactions = <String, List<FinanceTransaction>>{};
                for (var transaction in transactions) {
                  groupedTransactions.putIfAbsent(transaction.category, () => []);
                  groupedTransactions[transaction.category]!.add(transaction);
                }

                // Sort the transactions in each category by date
                groupedTransactions.forEach((category, transactionsList) {
                  transactionsList.sort((a, b) => b.date.compareTo(a.date));
                });

                return ListView(
                  children: groupedTransactions.entries.map((entry) {
                    final category = entry.key;
                    final categoryTransactions = entry.value;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                // Navigate to the detailed view for the selected category
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryTransactionsPage(
                                      category: category,
                                      transactions: categoryTransactions,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                          // Show a preview of the first few transactions in this category
                          Column(
                            children: categoryTransactions
                                .take(3) // Show up to 3 transactions as a preview
                                .map((transaction) {
                              return ListTile(
                                title: Text(transaction.title),
                                subtitle: Text(transaction.category),
                                trailing: Text(
                                  '\$${transaction.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: transaction.type == 'income'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTransactionsPage extends StatelessWidget {
  final String category;
  final List<FinanceTransaction> transactions;

  const CategoryTransactionsPage({
    required this.category,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          category,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            color: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                transaction.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(transaction.category),
              trailing: Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
