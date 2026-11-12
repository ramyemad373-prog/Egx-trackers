import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  List> _stocks = [];
  String? _selectedSymbol;
  String _type = 'BUY';
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  void _loadStocks() async {
    final stocks = await DBHelper().getAllStocks();
    setState(() {
      _stocks = stocks;
      if (_stocks.isNotEmpty) _selectedSymbol = _stocks.first['symbol'];
    });
  }

  void _saveTransaction() async {
    if (_selectedSymbol == null || _quantityController.text.isEmpty || _priceController.text.isEmpty) return;

    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0.0;

    if (quantity <= 0 || price <= 0) return;

    await DBHelper().insertTransaction(
      stockSymbol: _selectedSymbol!,
      type: _type,
      quantity: quantity,
      price: price,
      date: _selectedDate,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل عملية جديدة'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'BUY', label: Text('شراء'), icon: Icon(Icons.add_shopping_cart)),
                ButtonSegment(value: 'SELL', label: Text('بيع'), icon: Icon(Icons.sell)),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => _type = newSelection.first);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSymbol,
              decoration: const InputDecoration(labelText: 'اختر السهم', border: OutlineInputBorder()),
              items: _stocks.map((stock) {
                return DropdownMenuItem<String>(value: stock['symbol'], child: Text(stock['symbol']));
              }).toList(),
              onChanged: (val) => setState(() => _selectedSymbol = val),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'عدد الأسهم', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'سعر السهم (بالجنيه)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: _saveTransaction,
              child: const Text('حفظ العملية', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
