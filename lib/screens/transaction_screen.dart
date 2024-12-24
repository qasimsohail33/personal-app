import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_app/screens/LoginScreen.dart';
import '../models/transactions.dart';
import 'package:personal_app/serrvices/database_services.dart';
import '../serrvices/notf_service.dart';
class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchUserBalance();
  }

  double _balance = 0.0; // Variable to store the user's balance
  // Fetch the user's full name
  Future<void> _fetchUserName() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        _fullName = doc['fullName'];
      });
    }
  }
  // Fetch the user's balance
  Future<void> _fetchUserBalance() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        _balance = doc['balance'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return LoginScreen();
    }
    final databaseService = DatabaseService(userId: userId);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade500, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title:
                    Row(
                      mainAxisSize: MainAxisSize.min, // Ensure Row only takes as much space as its children
                      children: [
                        // Container wraps Image to constrain size
                        Container(
                          width: 30,  // Adjusted width for better control
                          //height: 35, // Adjusted height for better fitting
                          child: Image(
                            image: AssetImage("assets/logopng.png"),
                            fit: BoxFit.contain, // Ensure the logo scales proportionally
                          ),

                        ),
                        //SizedBox(width: 10), // Spacing between the logo and the text
                        // Icon(
                        //   Icons.ac_unit_outlined,
                        //   color: Colors.white,
                        // ),
                        SizedBox(width: 4), // Spacing between icon and text
                        Text(
                          'Monifest',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    actions: [
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                child: Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: [
                        Text(
                          _fullName != null ? '$_fullName ' : 'Welcome!',
                          style: TextStyle(fontSize: 20,color: Colors.white60, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Current Balance: \$${_balance.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<FinanceTransaction>>(
                  stream: databaseService.getTransactions(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }
                    final transactions = snapshot.data!;

                    // Sort transactions by date, with the most recent first
                    transactions.sort((a, b) => b.date.compareTo(a.date));

                    return ListView.builder(
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ElevatedButton(
          onPressed: () {
            _showAddTransactionDialog(context, databaseService);
          },
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            backgroundColor: Colors.white,
            elevation: 8,

          ),
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
  void _showAddTransactionDialog(BuildContext context, DatabaseService databaseService) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    // Default error messages
    String titleError = '';
    String amountError = '';
    String typeError = '';
    String categoryError = '';

    showDialog(
      context: context,
      builder: (context) {
        String selectedType = 'income'; // Default value
        String selectedCategory = 'Miscellaneous'; // Default category
        final categories = ['Food', 'Travel', 'Shopping', 'Bills', 'Miscellaneous']; // Example categories

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Add Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        errorText: titleError.isEmpty ? null : titleError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        errorText: amountError.isEmpty ? null : amountError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type',
                          style: TextStyle(fontSize: 16), // Label text for the radio button group
                        ),
                        ...['income', 'expense'].map(
                              (type) => RadioListTile<String>(
                            title: Text(type), // Display the text for the radio button
                            value: type,
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                                typeError = ''; // Clear error when user selects a type
                              });
                            },
                          ),
                        ),
                        if (typeError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              typeError,
                              style: TextStyle(color: Colors.red, fontSize: 12), // Error text styling
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCategory.isNotEmpty ? selectedCategory : null, // Keep null initially to show hint
                      items: categories
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                          categoryError = ''; // Clear error when user selects a category
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category', // Label that acts like a placeholder
                        errorText: categoryError.isEmpty ? null : categoryError, // Display error if validation fails
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog immediately
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text;
                    final amount = double.tryParse(amountController.text) ?? 0.0;

                    // Reset error messages
                    setState(() {
                      titleError = '';
                      amountError = '';
                      typeError = '';
                      categoryError = '';
                    });

                    // Validation checks
                    bool isValid = true;


                    // Validate title
                    if (title.isEmpty) {
                      setState(() {
                        titleError = 'Title is required!';
                      });
                      isValid = false;
                    }

                    // Validate amount
                    if (amount <= 0.0) {
                      setState(() {
                        amountError = 'Amount must be greater than zero!';
                      });
                      isValid = false;
                    }

                    // Validate type
                    // Validation logic
                    if (selectedType.isEmpty) {
                      setState(() {
                        typeError = 'Please select a transaction type!';
                      });
                      isValid = false;
                    } else {
                      setState(() {
                        typeError = ''; // Clear the error when valid
                      });
                    }

// Validate category
                    if (selectedCategory.isEmpty) {
                      setState(() {
                        categoryError = 'Please select a category!';
                      });
                      isValid = false;
                    } else {
                      setState(() {
                        categoryError = ''; // Clear the error when valid
                      });
                    }

                    if (!isValid) return; // Don't proceed if validation fails


                    final transaction = FinanceTransaction(
                      id: '', // Firestore generates the ID
                      title: title,
                      amount: amount,
                      type: selectedType,
                      category: selectedCategory,
                      date: DateTime.now(),
                    );

                    // Close the dialog immediately
                    Navigator.of(context).pop();

                    // Perform async tasks after the dialog closes
                    await databaseService.addTransaction(transaction);

                    // Update the balance in Firestore
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      final balanceChange = selectedType == 'income' ? amount : -amount;
                      await FirebaseFirestore.instance.collection('users').doc(userId).update({
                        'balance': FieldValue.increment(balanceChange), // Increment or decrement the balance
                      });
                    }
                    await _fetchUserBalance();

                    // Send notification after updating balance
                    final userFcmToken = await NotificationService().getFcmToken();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.purple,
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}



