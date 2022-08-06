// ignore_for_file: prefer_const_constructors

import 'package:budget_tracker/model/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../view_models/budget_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) =>
              AddTransactionDialog(itemToAdd: (transactionItem) {
            final budgetViewModel =
                Provider.of<BudgetViewModel>(context, listen: false);
            budgetViewModel.addItem(transactionItem);
          }),
        ),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: screenSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Consumer<BudgetViewModel>(
                      builder: ((context, value, child) {
                    final balance = value.getBalance();
                    final budget = value.getBudget();
                    double percentage = balance / budget;

                    if (percentage < 0) {
                      percentage = 0;
                    }
                    if (percentage > 1) {
                      percentage = 1;
                    }
                    return CircularPercentIndicator(
                      radius: screenSize.width / 2,
                      lineWidth: 10,
                      percent: percentage,
                      backgroundColor: Colors.white,
                      center: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          "₹${balance.toString().split(".")[0]}",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Expend",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "Budget: ₹${budget.toString().split(".")[0]}",
                          style: TextStyle(fontSize: 10),
                        )
                      ]),
                      progressColor: Theme.of(context).colorScheme.primary,
                    );
                  })),
                ),
                const SizedBox(
                  height: 35,
                ),
                const Text(
                  "Expenses",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<BudgetViewModel>(builder: ((context, value, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: value.items.length,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return TransactionCard(
                        item: value.items[index],
                      );
                    },
                  );
                }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionItem item;

  const TransactionCard({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(children: [
                const Text("Delete item"),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final budgetViewModel =
                        Provider.of<BudgetViewModel>(context, listen: false);
                    budgetViewModel.deleteItem(item);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                )
              ]),
            ),
          );
        },
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, top: 5),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  offset: const Offset(0, 25),
                  blurRadius: 50,
                )
              ]),
          padding: const EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              item.itemTitle,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              (!item.isExpense ? "+ " : "- ") + item.amount.toString(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionItem) itemToAdd;
  const AddTransactionDialog({required this.itemToAdd, Key? key})
      : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController itemTitleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool _isExpenseController = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(children: [
            Text(
              "Add as expense",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: itemTitleController,
              decoration: InputDecoration(hintText: "Name of expense"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(hintText: "Amount in \$"),
            ),
            Row(
              children: [
                const Text("Is expense?"),
                Switch(
                  value: _isExpenseController,
                  onChanged: ((value) => setState(() {
                        _isExpenseController = value;
                      })),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () {
                if (itemTitleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  widget.itemToAdd(TransactionItem(
                    itemTitle: itemTitleController.text,
                    amount: double.parse(amountController.text),
                    isExpense: _isExpenseController,
                  ));
                  Navigator.pop(context);
                }
              },
            )
          ]),
        ),
      ),
    );
  }
}
