import 'package:budget_tracker/model/transaction_item.dart';
import 'package:hive_flutter/adapters.dart';

class LocalStorageService {
  static const String transactionsBoxKey = "transactionsBox";
  static const String balanceBoxKey = "balanceBox";
  static const String budgetBoxKey = "budgetBox";

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> initializeHive() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionItemAdapter());
    }

    await Hive.openBox<double>(budgetBoxKey);
    await Hive.openBox<TransactionItem>(transactionsBoxKey);
    await Hive.openBox<double>(balanceBoxKey);
  }

  void saveTransactionItem(TransactionItem transaction) {
    Hive.box<TransactionItem>(transactionsBoxKey).add(transaction);
    saveBalance(transaction);
  }

  List<TransactionItem> getAllTransactions() {
    return Hive.box<TransactionItem>(transactionsBoxKey).values.toList();
  }

  void deleteTransactionItem(TransactionItem transaction) {
    final transactions = Hive.box<TransactionItem>(transactionsBoxKey);
    final Map<dynamic, TransactionItem> map = transactions.toMap();
    dynamic desiredKey;
    map.forEach((key, value) {
      if (value.itemTitle == transaction.itemTitle) desiredKey = key;
    });

    transactions.delete(desiredKey);
    saveBalanceOnDelete(transaction);
  }

  double exceptionHandling(double currentbalance, double amount) {
    double result = currentbalance - amount;
    if (result < 0) result = 0;
    return result;
  }

  double exceptionHandling_2(double currentbalance, double amount) {
    return currentbalance == 0 ? 0 : currentbalance + amount;
  }

  Future<void> saveBalance(TransactionItem item) async {
    final balanceBox = Hive.box<double>(balanceBoxKey);
    final currentbalance = balanceBox.get("balance") ?? 0;
    if (item.isExpense) {
      balanceBox.put("balance", currentbalance + item.amount);
    } else {
      balanceBox.put("balance", exceptionHandling(currentbalance, item.amount));
    }
  }

  Future<void> saveBalanceOnDelete(TransactionItem item) async {
    final balanceBox = Hive.box<double>(balanceBoxKey);
    final currentbalance = balanceBox.get("balance") ?? 0;
    if (item.isExpense) {
      balanceBox.put("balance", currentbalance - item.amount);
    } else {
      balanceBox.put(
          "balance", exceptionHandling_2(currentbalance, item.amount));
    }
  }

  double getBalance() {
    return Hive.box<double>(balanceBoxKey).get("balance") ?? 0.0;
  }

  Future<void> saveBudget(double budget) {
    return Hive.box<double>(budgetBoxKey).put("budget", budget);
  }

  double getBudget() {
    return Hive.box<double>(budgetBoxKey).get("budget") ?? 2000.0;
  }
}
