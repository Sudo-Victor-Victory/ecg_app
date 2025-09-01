import 'package:ecg_app/views/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
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
          TextField(
            controller: controllerEmail,
            onEditingComplete: () => setState(() {}),
            decoration: InputDecoration(
              labelText: "Email address",
              hintText: "Your email",
            ),
          ),

          TextField(
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
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          Center(
            child: FilledButton(
              onPressed: () async {
                print("attempting signup");
                var idk = await signUp();
                if (idk != null) {
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
              // onPressed: () => Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) {
              //       return WidgetTree();
              //     },
              //   ),
              // ),
              child: Text("Sign up"),
            ),
          ),
          Center(
            child: FilledButton(
              onPressed: () async {
                var idk = await signIn();
                if (idk != null) {
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

              child: Text("Go to login page"),
            ),
          ),
        ],
      ),
    );
  }

  Future<User?> signUp() async {
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

  Future<User?> signIn() async {
    final supabase = Supabase.instance.client;
    try {
      final res = await supabase.auth.signInWithPassword(
        email: controllerEmail.text,
        password: controllerPassword.text,
      );

      if (res.user != null) {
        print("Logged in");
        return res.user;
      } else {
        return null;
      }
    } on AuthApiException {
      if (!mounted) {
        return null;
      }
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Failure in logging in'),
          content: SizedBox(
            width: 200.0,
            height: 100.0,
            child: Column(
              children: [Text('Could not sign in with credentials')],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return null;
  }
}
