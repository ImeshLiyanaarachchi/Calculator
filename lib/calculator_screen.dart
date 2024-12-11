//IM/2021/027 IMESH
import 'package:flutter/material.dart';
import 'package:calculator/button_values.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = "";
  String result = "0";
  String previousResult = "";

  List<String> history = [];
  bool showHistory = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(showHistory ? Icons.history : Icons.history_toggle_off),
            onPressed: () {
              setState(() {
                showHistory = !showHistory;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (showHistory) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(history[index]),
                      onTap: () {
                        setState(() {
                          expression += history[index].split("=")[0];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
            if (!showHistory) ...[
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          expression.isEmpty ? "" : expression,
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result,
                          style: TextStyle(
                              fontSize: result == "Error" ? 32 : 48,
                              fontWeight: FontWeight.bold,
                              color: result == "Error"
                                  ? Colors.red
                                  : Colors.green),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: value == Btn.n0
                          ? screenSize.width / 2
                          : screenSize.width / 4,
                      height: screenSize.width / 6,
                      child: buildButton(value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSpecialButton(value) ? 36 : 24,
                color: getButtonTextColor(value),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isSpecialButton(String value) {
    return [
      Btn.add,
      Btn.subtract,
      Btn.multiply,
      Btn.divide,
      Btn.per,
      Btn.minors,
      Btn.square,
      Btn.calculate,
    ].contains(value);
  }

  Color getButtonTextColor(String value) {
    if (value == Btn.del || value == Btn.clr) {
      return Colors.red;
    }
    if (value == Btn.calculate) {
      return Colors.white;
    }
    if (isSpecialButton(value)) {
      return Colors.green;
    }
    return Colors.black;
  }

  Color getBtnColor(String value) {
    if (value == Btn.calculate) {
      return Colors.green;
    }
    if (value == Btn.del || value == Btn.clr) {
      return const Color(0xFFEEEEF0);
    }

    if ([
      Btn.add,
      Btn.subtract,
      Btn.multiply,
      Btn.divide,
      Btn.per,
      Btn.minors,
      Btn.square,
      Btn.openbracket,
      Btn.closebracket
    ].contains(value)) {
      return const Color(0xFFEEEEF0);
    }

    return const Color(0xFFEEEEF0);
  }

  void onBtnTap(String value) {
    setState(() {
      if (result != "0" &&
          value != Btn.del &&
          value != Btn.clr &&
          !isOperator(value)) {
        expression = value;
        result = "0";
        previousResult = "";
        return;
      }

      if (isOperator(value) &&
          isOperator(
              expression.isEmpty ? '' : expression[expression.length - 1])) {
        expression = expression.substring(0, expression.length - 1) + value;
        return;
      }

      if (isOperator(value) && expression.isEmpty) {
        return;
      }

      if (value == Btn.del) {
        delete();
      } else if (value == Btn.clr) {
        clearAll();
      } else if (value == Btn.calculate) {
        calculate();
      } else if (value == Btn.square) {
        appendValue("√(");
      } else if (value == Btn.minors) {
        toggleSign();
      } else if (value == Btn.openbracket || value == Btn.closebracket) {
        appendValue(value);
      } else {
        appendValue(value);
      }
    });
  }

  void clearAll() {
    setState(() {
      expression = "";
      result = "0";
      previousResult = "";
    });
  }

  void delete() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
    }
  }

  void appendValue(String value) {
    if (expression == "Error") {
      expression = "";
    }

    expression += value;
  }

  bool isOperator(String value) {
    return value == Btn.add ||
        value == Btn.subtract ||
        value == Btn.multiply ||
        value == Btn.divide;
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      String formatted = value.toStringAsFixed(10);

      if (formatted.contains('.') && formatted.endsWith('0')) {
        formatted = formatted.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
      }
      return formatted;
    }
  }

  void calculate() {
    if (expression.isEmpty) return;

    try {
      expression = handleAdjacentParentheses(expression);

      if (expression.contains('/0')) {
        result = "Undefined";
        previousResult = "";
        return;
      }

      String parsedExpression = expression
          .replaceAll(Btn.multiply, '*')
          .replaceAll(Btn.divide, '/')
          .replaceAll(Btn.per, '/100')
          .replaceAll("√", "sqrt");

      Parser parser = Parser();
      Expression exp = parser.parse(parsedExpression);
      ContextModel contextModel = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, contextModel);

      if (eval.isInfinite || eval.isNaN) {
        result = "Undefined";
      } else {
        result = _formatResult(eval);
      }

      history.insert(0, "$expression = $result");

      previousResult = result;
    } catch (e) {
      result = "Error";
      previousResult = "";
    }

    setState(() {});
  }

  String handleAdjacentParentheses(String expression) {
    String result = expression;

    result = result.replaceAllMapped(RegExp(r'(\d)(\()'), (match) {
      return '${match.group(1)}*${match.group(2)}';
    });

    result = result.replaceAllMapped(RegExp(r'(\))(\d)'), (match) {
      return '${match.group(1)}*${match.group(2)}';
    });

    result = result.replaceAllMapped(RegExp(r'\)(\()'), (match) {
      return ')*(';
    });

    return result;
  }

  void toggleSign() {
    if (expression.isNotEmpty) {
      if (expression.startsWith('-')) {
        expression = expression.substring(1);
      } else {
        expression = "-$expression";
      }
    } else {
      expression = "-";
    }
  }
}
