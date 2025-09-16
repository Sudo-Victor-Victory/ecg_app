import 'package:ecg_app/utils/dialog_alert.dart';
import 'package:ecg_app/views/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  bool passwordVisible = false;
  static const List<String> list = <String>[
    'For fun',
    'I like ECGs',
    'Idk',
    'Why are you still reading this',
  ];
  String? dropdownValue;

  String? signUpReason;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up", selectionColor: Color(0xFF1D1B14)),
        backgroundColor: Color(0xFF07A0C3),
      ),
      body: SingleChildScrollView(
        child: FractionallySizedBox(
          child: Column(
            children: [
              Center(
                child: Text(
                  "Sign up for\nReal Time ECG (RTECG)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 30.0,
                  ),
                ),
              ),
              SizedBox(
                child: Lottie.asset(
                  'assets/lotties/ecg.json',
                  fit: BoxFit.cover,
                  height: 350.0,
                  width: 400,
                ),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: controllerEmail,
                  onEditingComplete: () => setState(() {}),
                  decoration: InputDecoration(
                    labelText: "Email address",
                    hintText: "Your email",
                  ),
                ),
              ),

              SizedBox(
                width: 250,

                child: TextField(
                  controller: controllerPassword,
                  obscureText: !passwordVisible,
                  onEditingComplete: () => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Enter your account's password",
                    labelText: "Password",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ),
              Center(child: Text("Reason for joining?")),
              DropdownButton<String>(
                value: dropdownValue,
                hint: const Text("Select a reason"),
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(height: 2, color: Colors.deepPurpleAccent),
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Center(
                child: FilledButton(
                  onPressed: () async {
                    User? newUser;
                    print("attempting sign up");
                    newUser = await signUp();

                    if (newUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return WidgetTree();
                          },
                        ),
                      );
                    }
                  },
                  child: Text("You know you wanna sign up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<User?> signUp() async {
    try {
      final supabase = Supabase.instance.client;

      final res = await supabase.auth.signUp(
        email: controllerEmail.text,
        password: controllerPassword.text,
      );

      if (res.user != null) {
        print("Signed up");
        print(res.toString());
      }

      return res.user;
    }
    // catches weak password
    on AuthWeakPasswordException catch (e) {
      await showErrorDialog(
        context,
        "Weak password",
        "Use at least 6 characters, 1 upercase, and at least 1 symbol ",
      );
    }
    // catches other API errors (like email already used)
    on AuthApiException catch (e) {
      await showErrorDialog(context, "Sign up failed", e.message);
    }
    // optional catch-all
    catch (e) {
      await showErrorDialog(
        context,
        "Unexpected error  try again later",
        e.toString(),
      );
    }

    return null;
  }
}
