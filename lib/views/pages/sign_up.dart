import 'package:ecg_app/views/widgets/widget_tree.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up", selectionColor: Color(0xFF1D1B14)),
        backgroundColor: Color(0xFF07A0C3),
      ),
      body: Column(
        children: [
          Text("Hi you are in the sign up page"),
          Center(
            child: FilledButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return WidgetTree();
                  },
                ),
              ),
              child: Text("Go to home"),
            ),
          ),
        ],
      ),
    );
  }
}
