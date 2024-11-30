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
  String expression = ""; // Stores the input expression
  String result = "0"; // Stores the result preview
  String previousResult = ""; // Store the previous result

  // History list to store previous operations and results
  List<String> history = [];
  bool showHistory = false; // Flag to toggle history display

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
                showHistory = !showHistory; // Toggle history view
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // History view (shown when showHistory is true)
            if (showHistory) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(history[index]),
                      onTap: () {
                        setState(() {
                          // When a history entry is clicked, append it to the expression
                          expression += history[index].split("=")[0];
                        });
                        Navigator.pop(context); // Close the history view
                      },
                    );
                  },
                ),
              ),
            ],

            // Display area for the expression and result (shown when showHistory is false)
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

            // Calculator buttons layout
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

  // Helper function to build buttons with dynamic styling
  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value), // Get the color for each button
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
                color: getButtonTextColor(value), // Set text color dynamically
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to check if the button is one of the special buttons
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

  // Helper function to get the button's text color
  Color getButtonTextColor(String value) {
    if (value == Btn.del || value == Btn.clr) {
      return Colors.red; // Del and Clr buttons text color is red
    }
    if (value == Btn.calculate) {
      return Colors.white; // Calculate button text color is white
    }
    if (isSpecialButton(value)) {
      return Colors.green; // Special buttons text color is green
    }
    return Colors.black; // Default for numbers and operands is black
  }

  // Helper function to get the button color based on its value
  Color getBtnColor(String value) {
    if (value == Btn.calculate) {
      return Colors.green; // Color for the equal button
    }
    if (value == Btn.del || value == Btn.clr) {
      return const Color(0xFFEEEEF0); // Color for delete and clear buttons
    }
    // Color for operand buttons like +, -, *, /
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
    // Default color for numbers and other buttons
    return const Color(0xFFEEEEF0);
  }

  // Handle button press
  void onBtnTap(String value) {
    setState(() {
      // Check if the result is already displayed, and if the value is a number
      if (result != "0" &&
          value != Btn.del &&
          value != Btn.clr &&
          !isOperator(value)) {
        // If a number is pressed after a result, reset and start a new calculation
        expression = value; // Start the new calculation with the pressed number
        result = "0"; // Reset the result
        previousResult = ""; // Clear the previous result
        return;
      }

      // Prevent consecutive operand inputs and ensure operand can replace the previous one
      if (isOperator(value) &&
          isOperator(
              expression.isEmpty ? '' : expression[expression.length - 1])) {
        // If operand is pressed twice, replace the last one
        expression = expression.substring(0, expression.length - 1) + value;
        return;
      }

      // Prevent operand entry before the first number
      if (isOperator(value) && expression.isEmpty) {
        return; // Do nothing if the first input is an operand
      }

      if (value == Btn.del) {
        delete();
      } else if (value == Btn.clr) {
        clearAll();
      } else if (value == Btn.calculate) {
        calculate();
      } else if (value == Btn.square) {
        appendValue("√("); // Add √( for square root
      } else if (value == Btn.minors) {
        toggleSign();
      } else if (value == Btn.openbracket || value == Btn.closebracket) {
        appendValue(value);
      } else {
        appendValue(value);
      }

      // Update result preview after each input or operand
    });
  }

  void clearAll() {
    setState(() {
      expression = "";
      result = "0"; // Reset result to "0"
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

    // Append the value to the expression
    expression += value;
  }

  // Function to check if a character is an operator
  bool isOperator(String value) {
    return value == Btn.add ||
        value == Btn.subtract ||
        value == Btn.multiply ||
        value == Btn.divide;
  }

  // Helper function to format the result
  String _formatResult(double value) {
    if (value == value.toInt()) {
      // If the value is a whole number, return it as an integer (no decimals)
      return value.toInt().toString();
    } else {
      // If the value is a decimal, return it formatted to 10 decimal places
      String formatted = value.toStringAsFixed(10);

      // Remove trailing zeros after decimal
      if (formatted.contains('.') && formatted.endsWith('0')) {
        formatted = formatted.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
      }
      return formatted;
    }
  }

  // Calculation function
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

      // Save the expression and result to history
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

    // Handling cases where parentheses are adjacent to numbers
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
