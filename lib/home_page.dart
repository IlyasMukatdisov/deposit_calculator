import 'package:deposit_calculator/models.dart';
import 'package:deposit_calculator/utils/extensions.dart';
import 'package:deposit_calculator/utils/functions.dart';
import 'package:deposit_calculator/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _requiredAmountController;
  late final TextEditingController _percentController;
  late final TextEditingController _replenishmentController;
  late Period _period;
  final _formKey = GlobalKey<FormState>();
  int _requiredDays = 0;
  int _requiredMonths = 0;
  int _calculatingYear = 0;
  double _requiredAmount = 0.0;
  double _percent = 0.0;
  double _replenishment = 0.0;
  double _depositAmount = 0.0;
  double _monthPercentageAmount = 0.0;
  late int _monthIndex;

  @override
  void initState() {
    _requiredAmountController = TextEditingController();
    _percentController = TextEditingController();
    _replenishmentController = TextEditingController();
    _period = Period.month;
    _calculatingYear = DateTime.now().year;
    _monthIndex = DateTime.now().month;
    _changeMonth();
    super.initState();
  }

  @override
  void dispose() {
    _requiredAmountController.dispose();
    _percentController.dispose();
    _replenishmentController.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid amount';
    }

    return null;
  }

  void _calculateForYear() {
    final year = _calculatingYear;
    final isCurrentYearLeap = isLeapYear(_calculatingYear);
    final dailyPercentage = _percent / (isCurrentYearLeap ? 366 : 365) / 100;

    while (_depositAmount <= _requiredAmount && _calculatingYear == year) {
      int countDaysInMonth = 0;
      if (monthsWith31Days.contains(_monthIndex)) {
        countDaysInMonth = 31;
      }
      if (monthsWith30Days.contains(_monthIndex)) {
        countDaysInMonth = 30;
      }
      if (_monthIndex == february) {
        if (isCurrentYearLeap) {
          countDaysInMonth = 29;
        } else {
          countDaysInMonth = 28;
        }
      }
      if (_period == Period.month) {
        _calcMonthAmount(countDaysInMonth, dailyPercentage);
      }
      if (_period == Period.day) {
        _calcDailyAmount(dailyPercentage, countDaysInMonth);
      }
    }
  }

  void _calcMonthAmount(int countDaysInMonth, double dailyPercentage) {
    _depositAmount += _replenishment;
    _monthPercentageAmount = _calculateMonthPercentage(
      countDaysInMonth: countDaysInMonth,
      amount: _requiredAmount,
      dailyPercentage: dailyPercentage,
    );
    _depositAmount += _monthPercentageAmount;
    _monthPercentageAmount = 0;
    _changeMonth();
  }

  void _calcDailyAmount(double dailyPercentage, int countDaysInMonth) {
    _monthPercentageAmount = _calculateDailyPercentage(
      countDaysInMonth: countDaysInMonth,
      amount: _requiredAmount,
      dailyPercentage: dailyPercentage,
    );
    _depositAmount += _monthPercentageAmount;
    _monthPercentageAmount = 0;
    _changeMonth();
  }

  double _calculateMonthPercentage({
    required int countDaysInMonth,
    required double amount,
    required double dailyPercentage,
  }) {
    double monthPercentageAmount = 0;
    for (int i = 0; i < countDaysInMonth; i++) {
      monthPercentageAmount += dailyPercentage * _depositAmount;
      _requiredDays++;
    }
    _requiredMonths++;
    return monthPercentageAmount;
  }

  double _calculateDailyPercentage({
    required int countDaysInMonth,
    required double amount,
    required double dailyPercentage,
  }) {
    double monthPercentageAmount = 0;
    for (int i = 0; i < countDaysInMonth; i++) {
      _depositAmount += _replenishment;
      monthPercentageAmount += dailyPercentage * _depositAmount;
      _requiredDays++;
    }
    _requiredMonths++;
    return monthPercentageAmount;
  }

  void _changeMonth() {
    if (_monthIndex < DateTime.december) {
      _monthIndex++;
      return;
    }
    _monthIndex = DateTime.january;
    _calculatingYear++;
  }

  void _clear() {
    _calculatingYear = DateTime.now().year;
    _monthIndex = DateTime.now().month;
    _changeMonth();
    _requiredDays = 0;
    _requiredMonths = 0;
    _calculatingYear = 0;
    _requiredAmount = 0.0;
    _percent = 0.0;
    _replenishment = 0.0;
    _depositAmount = 0.0;
    _monthPercentageAmount = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Calculator'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: _numberValidator,
                        controller: _requiredAmountController,
                        decoration: const InputDecoration(
                          label: Text('Amount'),
                          suffixText: 'UZS',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: _numberValidator,
                        controller: _percentController,
                        decoration: const InputDecoration(
                          label: Text('Percent'),
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: _numberValidator,
                        controller: _replenishmentController,
                        decoration: const InputDecoration(
                          label: Text('Replenishment'),
                          suffixText: 'UZS',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      flex: 1,
                      child: DropdownButtonFormField<Period>(
                        value: _period,
                        onChanged: (value) {
                          if (value != null) {
                            setState(
                              () {
                                _period = value;
                              },
                            );
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: Period.day,
                            child: Text(Period.day.name.capitalize()),
                          ),
                          DropdownMenuItem(
                            value: Period.month,
                            child: Text(Period.month.name.capitalize()),
                          ),
                        ],
                        validator: (value) {
                          if (value == null) {
                            return 'Please select period';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Period'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _clear();
                            _requiredAmount =
                                double.parse(_requiredAmountController.text);
                            _percent = double.parse(_percentController.text);
                            _replenishment =
                                double.parse(_replenishmentController.text);

                            while (_depositAmount < _requiredAmount) {
                              _calculateForYear();
                            }
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          minimumSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Calculate'),
                      ),
                    ),
                  ],
                ),
                _requiredMonths > 0 && _formKey.currentState!.validate()
                    ? Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                              'Requested amount of ${_depositAmount.toStringAsFixed(2)} UZS will be achieved in ${_requiredMonths ~/ 12} years and ${_requiredMonths % 12} month (total $_requiredDays days) by $_percent% per year'),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
