import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark(),
      home: const CalculatorHomePage(),
    );
  }
}

/// Логика калькулятора
class CalculatorLogic {
  double? _firstNumber;
  String? _operation;
  bool _waitingForSecond = false;

  String display = '0';

  /// Ввод цифры или точки
  void input(String value) {
    if (value == '.' && display.contains('.')) return;
    if (_waitingForSecond) {
      display = value;
      _waitingForSecond = false;
    } else {
      display = display == '0' && value != '.' ? value : display + value;
    }
  }

  /// Очистка всего
  void clearAll() {
    display = '0';
    _firstNumber = null;
    _operation = null;
    _waitingForSecond = false;
  }

  /// Очистка только текущего числа
  void clearEntry() {
    display = '0';
  }

  /// Установка операции (+, -, *, /)
  void setOperation(String op) {
    if (_operation != null) calculate();
    _firstNumber = double.tryParse(display);
    _operation = op;
    _waitingForSecond = true;
  }

  /// Вычисление результата
  void calculate() {
    if (_operation == null || _firstNumber == null) return;
    double secondNumber = double.tryParse(display) ?? 0;
    double result = 0;

    try {
      switch (_operation) {
        case '+':
          result = _firstNumber! + secondNumber;
          break;
        case '-':
          result = _firstNumber! - secondNumber;
          break;
        case '*':
          result = _firstNumber! * secondNumber;
          break;
        case '/':
          if (secondNumber == 0) throw Exception("Деление на ноль");
          result = _firstNumber! / secondNumber;
          break;
      }
      display = result % 1 == 0 ? result.toInt().toString() : result.toString();
      _firstNumber = result;
      _operation = null;
      _waitingForSecond = true;
    } catch (e) {
      display = 'Ошибка';
      _firstNumber = null;
      _operation = null;
      _waitingForSecond = false;
    }
  }

  /// Обработка процента
  void percent() {
    double current = double.tryParse(display) ?? 0;
    if (_firstNumber != null && _operation != null) {
      // Вычисляем процент от первого числа для цепочки операций
      current = _firstNumber! * current / 100;
    } else {
      // Просто делим число на 100
      current = current / 100;
    }
    display = current.toString();
  }

  /// Удаление последнего символа
  void backspace() {
    if (display.isNotEmpty) {
      display = display.substring(0, display.length - 1);
      if (display.isEmpty) {
        display = '0';
      }
    }
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  final CalculatorLogic calc = CalculatorLogic();

  final List<String> buttons = [
    'CE', 'C', '%', '/',
    '7', '8', '9', '*',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '=', '⌫', // Добавлена кнопка Backspace
  ];

  Color _getButtonColor(String value) {
    if ('+-*/='.contains(value)) return Colors.orange;
    if ('CEC%'.contains(value)) return Colors.redAccent;
    return Colors.grey[850]!;
  }

  void _onPressed(String value) {
    setState(() {
      if ('0123456789.'.contains(value)) {
        calc.input(value);
      } else if ('+-*/'.contains(value)) {
        calc.setOperation(value);
      } else if (value == '=') {
        calc.calculate();
      } else if (value == 'C') {
        calc.clearAll();
      } else if (value == 'CE') {
        calc.clearEntry();
      } else if (value == '%') {
        calc.percent();
      } else if (value == '⌫') {
        calc.backspace(); // Обработка кнопки Backspace
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonHeight = (screenHeight - 200) / 6;
    double buttonWidth = screenWidth / 4 - 12;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Дисплей калькулятора
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Text(
                  calc.display,
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Кнопки
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: buttons.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: buttonWidth / buttonHeight,
                  ),
                  itemBuilder: (context, index) {
                    final value = buttons[index];
                    return GestureDetector(
                      onTap: () => _onPressed(value),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getButtonColor(value),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
