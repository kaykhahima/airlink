import 'package:flutter/material.dart';

class InputField extends StatefulWidget {

  const InputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: SizedBox(
            height: 50.0,
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: const TextStyle(
                  fontSize: 15.0,
                ),
                isDense: true,
              ),
              validator: widget.validator,
            ),
          ),
        ),
        const SizedBox(
          height: 12.0,
        ),
      ],
    );
  }
}
