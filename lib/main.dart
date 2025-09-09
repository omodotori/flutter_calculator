import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDarkMode = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
      ),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: CalculatorHomePage(
        isDarkMode: isDarkMode,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}

class CalculatorLogic {
  double? _firstNumber;
  String? _operation;
  bool _waitingForSecond = false;
  String display = '0';
  String _previousDisplay = '0';

  double memory = 0;

  void input(String value) {
    _previousDisplay = display;
    if (value == '.' && display.contains('.')) return;
    display = _waitingForSecond ? value : (display == '0' ? value : display + value);
    _waitingForSecond = false;
  }

  void clearAll() {
    _previousDisplay = display;
    display = '0';
    _firstNumber = null;
    _operation = null;
    _waitingForSecond = false;
  }

  void clearEntry() {
    _previousDisplay = display;
    display = '0';
  }

  void setOperation(String op) {
    _previousDisplay = display;
    if (_operation != null) calculate();
    _firstNumber = double.tryParse(display);
    _operation = op;
    _waitingForSecond = true;
  }

  void calculate() {
    _previousDisplay = display;
    if (_operation == null || _firstNumber == null) return;
    double secondNumber = double.tryParse(display) ?? 0;
    try {
      double result;
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
        default:
          result = 0;
      }
      display = result % 1 == 0 ? result.toInt().toString() : result.toString();
      _firstNumber = result;
      _operation = null;
      _waitingForSecond = true;
    } catch (_) {
      display = 'Ошибка';
      clearAll();
    }
  }

  void percent() {
    double current = double.tryParse(display) ?? 0;
    display = (_firstNumber != null ? _firstNumber! * current / 100 : current / 100).toString();
  }

  void backspace() {
    display = display.length > 1 ? display.substring(0, display.length - 1) : '0';
  }

  void memoryAdd() {
    memory += double.tryParse(display) ?? 0;
  }

  void memorySubtract() {
    memory -= double.tryParse(display) ?? 0;
  }

  void memoryClear() {
    memory = 0;
  }

  void undo() {
    display = _previousDisplay;
  }
}

class CalculatorHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CalculatorHomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  final CalculatorLogic calc = CalculatorLogic();

  final List<String> buttons = [
    'MC', 'M+', 'M-', '%',
    'CE', 'C', '⌫', '/',
    '7', '8', '9', '*',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '=', 'Undo',
  ];

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
        calc.backspace();
      } else if (value == 'Undo') {
        calc.undo();
      } else if (value == 'M+') {
        calc.memoryAdd();
      } else if (value == 'M-') {
        calc.memorySubtract();
      } else if (value == 'MC') {
        calc.memoryClear();
      }
    });
  }

  Color _getButtonColor(String value) {
    if ('+-*/='.contains(value)) return Colors.orange;
    if ('C' == value || 'CE' == value || '%' == value) return Colors.redAccent;
    if (['MC', 'M+', 'M-'].contains(value)) return Colors.blueAccent;
    return widget.isDarkMode ? Colors.grey[850]! : Colors.grey[400]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final value = buttons[index];
                    return GestureDetector(
                      onTap: () => _onPressed(value),
                      onLongPress: value == 'C'
                          ? () => setState(() {
                              calc.clearAll();
                            })
                          : null,
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
