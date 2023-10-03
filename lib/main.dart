import 'package:adicionarcontames/number_formatter.dart';
import 'package:adicionarcontames/transaction_page.dart';
import 'package:adicionarcontames/transaction.dart';
import 'package:adicionarcontames/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'abc.dart';

// Importe a biblioteca para formatar datas

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const MyHomePage(),
        "/transaction": (context) => const TransactionPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  String selectedMonth = "Setembro";
  String selectedYear = "2023";

  bool _isExpanded = false;
  late final Function(String) onMonthChanged;
  late final Function(String) onYearChanged;
  late final Function(Transaction) onTransactionEdit;
  List<Transaction> transactions = [];
  List<Transaction> filteredTransactions = [];

  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double saldoPrevisto = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicialmente, exibe todas as transações
    updateFilteredTransactions();
  }

  void updateFilteredTransactions() {
    final mapping = {
      '1': 'Janeiro',
      '2': 'Fevereiro',
      '3': 'Março',
      '4': 'Abril',
      '5': 'Maio',
      '6': 'Junho',
      '7': 'Julho',
      '8': 'Agosto',
      '9': 'Setembro',
      '10': 'Outubro',
      '11': 'Novembro',
      '12': 'Dezembro',
    };

    filteredTransactions = transactions.where((transaction) {
      return mapping[transaction.month] == selectedMonth && transaction.year == selectedYear;
    }).toList();

    // Calcula o total de renda e despesas
    totalIncome = filteredTransactions.where((element) => element.type == TransactionType.income).fold(0.0, (sum, transaction) => sum + transaction.value);

    totalExpenses = filteredTransactions.where((element) => element.type == TransactionType.expense).fold(0.0, (sum, transaction) => sum + transaction.value);

    saldoPrevisto = totalIncome - totalExpenses;
  }

  void createTransaction(TransactionType type) {
    final newValue = Transaction(
      value: 0,
      name: '',
      date: DateTime.now(),
      type: type,
      category: '',
    );

    goToTransaction(newValue, (value) => transactions.add(value));
  }

  void editTransaction(int index, Transaction transaction) {
    goToTransaction(transaction, (value) => transactions[index] = value);
  }

  void goToTransaction(Transaction transaction, ValueSetter<Transaction> update) async {
    final result = await Navigator.of(context).pushNamed("/transaction", arguments: transaction);

    if (result is! Transaction) {
      return;
    }

    update(result);

    updateFilteredTransactions();
    _isExpanded = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // renda
    //  filteredTransactions.where((element) => element.type == TransactionType.income).toList();

    // despesa
    // filteredTransactions.where((element) => element.type == TransactionType.expense).toList();

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionListScreen(
                  transactions: transactions,
                  saldoPrevisto: saldoPrevisto,
                ),
              ),
            ).then((_) {
              updateFilteredTransactions();
            });
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 96, 106, 52),
            icon: Icon(Icons.home),
            label: '',
            activeIcon: Icon(
              Icons.home,
              color: Color.fromARGB(255, 96, 106, 52),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
            activeIcon: Icon(
              Icons.list,
              color: Color.fromARGB(255, 96, 106, 52),
            ),
          )
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: _isExpanded ? Alignment.center : Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isExpanded) ...[
              SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  heroTag: 'tab_renda',
                  backgroundColor: Colors.green,
                  onPressed: () => createTransaction(TransactionType.income),
                  tooltip: 'Renda',
                  child: const Icon(Icons.trending_up),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  heroTag: 'tab_despesa',
                  backgroundColor: Colors.red,
                  onPressed: () => createTransaction(TransactionType.expense),
                  tooltip: 'Despesa',
                  child: const Icon(Icons.trending_down_sharp),
                ),
              ),
              const SizedBox(height: 5),
            ],
            FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 96, 106, 52),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Icon(_isExpanded ? Icons.close : Icons.add),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color.fromARGB(255, 202, 219, 113),
                      Color.fromARGB(255, 96, 106, 52),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(500, 30),
                    bottomRight: Radius.elliptical(500, 30),
                  ),
                ),
                height: 307,
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedMonth,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                            updateFilteredTransactions();
                          });
                        },
                        items: <String>[
                          'Janeiro',
                          'Fevereiro',
                          'Março',
                          'Abril',
                          'Maio',
                          'Junho',
                          'Julho',
                          'Agosto',
                          'Setembro',
                          'Outubro',
                          'Novembro',
                          'Dezembro',
                        ].map(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedYear,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                            updateFilteredTransactions();
                          });
                        },
                        items: <String>[
                          '2022',
                          '2023',
                          '2024',
                          '2025',
                          '2026',
                        ].map(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  margin: const EdgeInsets.only(right: 20, left: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 96, 106, 52),
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  height: 200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo Previsto',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              Text(
                                'R\$${formatToCurrency(saldoPrevisto)}',
                                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Container(
                                padding: const EdgeInsets.only(right: 80),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Renda',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFD0E5E4),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatToCurrency(totalIncome),
                                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(16.0),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.trending_down,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Despesas',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFD0E5E4),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formatToCurrency(totalExpenses),
                                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                if (filteredTransactions.length > 5) PieChartWidget(transactions: filteredTransactions),
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Histórico De Transações',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final item = filteredTransactions[index];
                        final textColor = item.type == TransactionType.income ? Colors.green : Colors.red;
                        final signal = item.type == TransactionType.income ? "+" : "-";
                        return ListTile(
                          leading: const Icon(Icons.attach_money),
                          onTap: () => editTransaction(index, item),
                          title: Text(
                            item.name,
                            style: GoogleFonts.inter(
                                color: const Color(
                                  0xFF000000,
                                ),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(item.date)}'),
                          trailing: Text(
                            '$signal${formatToCurrency(item.value)}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
