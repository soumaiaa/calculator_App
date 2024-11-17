import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0"; // Affichage de l'expression complète
  String _expression = ""; // Expression complète pour calcul
  double? _result; // Résultat final

  // Fonction pour gérer les boutons
  void _buttonPressed(String value) {
    setState(() {
      if (value == "clear") {
        // Réinitialiser la calculatrice
        _output = "0";
        _expression = "";
        _result = null;
      } else if (value == "=") {
        // Calculer le résultat
        try {
          _result = _evaluateExpression(_expression);
          _output = _result!.toStringAsFixed(2).replaceAll(RegExp(r"\.00$"), "");
          _expression = _output; // Mettre le résultat comme nouvelle expression
        } catch (e) {
          _output = "Erreur";
        }
      } else {
        // Ajouter le chiffre ou l'opérateur à l'expression
        if (_output == "0" && !["+", "-", "×", "÷"].contains(value)) {
          _expression = value; // Remplacer "0" par le premier chiffre
        } else {
          _expression += value; // Ajouter le nouveau caractère
        }
        _output = _expression; // Mettre à jour l'affichage
      }
    });
  }

  // Fonction pour évaluer l'expression mathématique
  double _evaluateExpression(String expression) {
    expression = expression.replaceAll("×", "*").replaceAll("÷", "/");
    final parser = ExpressionParser();
    return parser.evaluate(expression);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Calculatrice"),
        backgroundColor: const Color.fromARGB(255, 247, 115, 236),
      ),
      body: Column(
        children: [
          // Affichage
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20.0),
              color: const Color.fromARGB(255, 247, 115, 236),
              child: Text(
                _output,
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
          ),
          // Boutons
          
          _buildButtonRow(["7", "8", "9", "+"]),
          _buildButtonRow(["4", "5", "6", "-"]),
          _buildButtonRow(["1", "2", "3", "×"]),
          _buildButtonRow(["clear","0","=", "÷"]),
        ],
      ),
    );
  }

  // Fonction pour créer une ligne de boutons
  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((button) {
          return Expanded(
            child: ElevatedButton(
              onPressed: () => _buttonPressed(button),
              style: ElevatedButton.styleFrom(
                backgroundColor: ["clear", "=", "+", "-", "×", "÷"]
                        .contains(button)
                    ? const Color.fromARGB(255, 238, 54, 244)
                    : Colors.white,
                foregroundColor: ["clear", "=", "+", "-", "×", "÷"]
                        .contains(button)
                    ? Colors.white
                    : Colors.black,
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                button,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Utilitaire pour évaluer l'expression mathématique
class ExpressionParser {
  double evaluate(String expression) {
    final tokens = _tokenize(expression);
    final postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  // Convertir une chaîne en liste de tokens (nombres et opérateurs)
  List<String> _tokenize(String expression) {
    final regex = RegExp(r'(\d+(\.\d+)?)|[+\-*/()]');
    return regex.allMatches(expression).map((e) => e.group(0)!).toList();
  }

  // Convertir une expression en notation postfixée (RPN)
  List<String> _toPostfix(List<String> tokens) {
    final precedence = {'+': 1, '-': 1, '*': 2, '/': 2};
    final output = <String>[];
    final operators = <String>[];

    for (final token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token); // Ajouter les nombres directement
      } else if (precedence.containsKey(token)) {
        while (operators.isNotEmpty &&
            precedence[operators.last]! >= precedence[token]!) {
          output.add(operators.removeLast());
        }
        operators.add(token);
      } else if (token == "(") {
        operators.add(token);
      } else if (token == ")") {
        while (operators.isNotEmpty && operators.last != "(") {
          output.add(operators.removeLast());
        }
        operators.removeLast();
      }
    }
    while (operators.isNotEmpty) {
      output.add(operators.removeLast());
    }
    return output;
  }

  // Évaluer une expression en notation postfixée (RPN)
  double _evaluatePostfix(List<String> postfix) {
    final stack = <double>[];
    for (final token in postfix) {
      if (double.tryParse(token) != null) {
        stack.add(double.parse(token));
      } else {
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            stack.add(a / b);
            break;
        }
      }
    }
    return stack.last;
  }
}
