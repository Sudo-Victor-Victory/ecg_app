import 'package:ecg_app/views/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  bool passwordVisible = false;

  bool isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up or Log in", selectionColor: Color(0xFF1D1B14)),
        backgroundColor: Color(0xFF07A0C3),
      ),
      body: SingleChildScrollView(
        child: FractionallySizedBox(
          child: Column(
            children: [
              Center(child: Text("Welcome to Real Time ECG (RTECG)")),
              SizedBox(
                child: Lottie.asset(
                  'assets/lotties/heart_and_ecg.json',
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
              Text("Switch me to change to ${isLogin ? "Sign up" : "Log in"}"),
              Switch.adaptive(
                value: isLogin,
                onChanged: (value) {
                  isLogin = !isLogin;
                  setState(() {});
                },
              ),
              Center(
                child: FilledButton(
                  onPressed: () async {
                    var idk;
                    if (isLogin) {
                      print("attempting log in");
                      idk = await signIn();
                    } else {
                      print("attempting sign up");
                      idk = await signUp();
                    }
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

                  child: Text(
                    isLogin
                        ? "Already have an account? Log in"
                        : "Don't have an account? Sign up",
                  ),
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
      _showErrorDialog(
        "Weak password",
        "Use at least 6 characters, 1 upercase, and at least 1 symbol ",
      );
    }
    // catches other API errors (like email already used)
    on AuthApiException catch (e) {
      _showErrorDialog("Sign up failed", e.message);
    }
    // optional catch-all
    catch (e) {
      _showErrorDialog("Unexpected error", e.toString());
    }

    return null;
  }

  Future<User?> signIn() async {
    try {
      final supabase = Supabase.instance.client;

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

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Center(child: Text(title)),
        content: SizedBox(
          width: 200.0,
          height: 100.0,
          child: Center(child: Text(message)),
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
}
