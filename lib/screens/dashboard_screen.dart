import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'stocks_screen.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List> _transactions = [];
  double _totalProfit = 0;
  double _totalPurification = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final transactions = await DBHelper().getAllTransactions();
    final stocks = await DBHelper().getAllStocks();

    Map<String, double> rates = {};
    for (var s in stocks) {
      rates[s['symbol']] = s['purification_rate'];
    }

    double totalP = 0;
    double totalPur = 0;
    for (var tx in transactions) {
      if (tx['type'] == 'SELL') {
        double profit = tx['total_amount'] * 0.1; // حساب تقريبي للربح
        double rate = rates[tx['stock_symbol']] ?? 0.0;
        totalP += profit;
        totalPur += (profit > 0 ? profit * rate : 0);
      }
    }

    setState(() {
      _transactions = transactions;
      _totalProfit = totalP;
      _totalPurification = totalPur;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم تداول الأسهم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StocksScreen())).then((_) => _loadData()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCard('إجمالي الأرباح', '${_totalProfit.toStringAsFixed(2)} ج.م', Colors.green)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildCard('إجمالي التطهير', '${_totalPurification.toStringAsFixed(2)} ج.م', Colors.orange)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('أحدث العمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _transactions.isEmpty
                    ? const Center(child: Text('لا توجد عمليات مسجلة'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          return Card(
                            child: ListTile(
                              title: Text('${tx['stock_symbol']} - ${tx['type']}'),
                              subtitle: Text('الكمية: ${tx['quantity']} | السعر: ${tx['price']}'),
                              trailing: Text('${tx['total_amount']} ج.م'),
                            ),
                          );
                        },
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())).then((_) => _loadData()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
