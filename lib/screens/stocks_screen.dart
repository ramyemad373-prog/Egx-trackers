import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  late Future<List>> _stocksFuture;

  @override
  void initState() {
    super.initState();
    _refreshStocks();
  }

  void _refreshStocks() {
    setState(() {
      _stocksFuture = DBHelper().getAllStocks();
    });
  }

  void _showAddOrEditStockDialog({String? symbol, double? rate}) {
    final symbolController = TextEditingController(text: symbol ?? '');
    final rateController = TextEditingController(text: rate != null ? rate.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(symbol == null ? 'إضافة سهم جديد' : 'تعديل نسبة التطهير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: symbolController,
              enabled: symbol == null,
              decoration: const InputDecoration(labelText: 'رمز السهم (مثال: COMI)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'نسبة التطهير (مثال: 0.025)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (symbolController.text.isNotEmpty && rateController.text.isNotEmpty) {
                String s = symbolController.text.toUpperCase();
                double r = double.tryParse(rateController.text) ?? 0.0;
                await DBHelper().addOrUpdateStock(s, r);
                _refreshStocks();
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الأسهم ونسب التطهير'), centerTitle: true),
      body: FutureBuilder<List>>(
        future: _stocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد أسهم مسجلة'));
          }

          final stocks = snapshot.data!;
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              double rate = stock['purification_rate'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(stock['symbol'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('نسبة التطهير: ${(rate * 100).toStringAsFixed(2)}%'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showAddOrEditStockDialog(symbol: stock['symbol'], rate: rate),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditStockDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
