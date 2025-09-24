import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/utils/dialog_alert.dart';
import 'package:ecg_app/views/pages/sign_up.dart';
import 'package:ecg_app/views/widgets/scaled_text.dart';
import 'package:ecg_app/views/widgets/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: ScaledText(
            "Sign in",
            baseSize: KTextSize.xxxl,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: KColors.eerieBlack,
            ),
          ),
        ),

        backgroundColor: KColors.blueGreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 20, // extra space
          ),
          child: FractionallySizedBox(
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Welcome to\nReal Time ECG (RTECG)",
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
                Padding(padding: EdgeInsetsGeometry.all(4)),
                Center(
                  child: FilledButton(
                    onPressed: () async {
                      var user;
                      print("attempting log in");
                      user = await signIn();

                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => WidgetTree()),
                        );
                      }
                    },

                    child: Text("Already have an account? Log in"),
                  ),
                ),
                Padding(padding: EdgeInsetsGeometry.all(4)),
                Center(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SignUpPage();
                          },
                        ),
                      );
                    },

                    child: Text("Don't have an account? Try signing up"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        final response = await supabase
            .from(KTables.userProfile)
            .select(KProfileColumns.firstName)
            .eq(
              'id',
              res.user!.id,
            ) // if you need to filter for the current user
            .single();

        firstName = response[KProfileColumns.firstName] as String;
        return res.user;
      } else {
        return null;
      }
    } on AuthApiException {
      if (!mounted) {
        return null;
      }
      showErrorDialog(
        context,
        "Failure in logging in",
        "Could not sign in with credentials",
      );
    }
    return null;
  }
}
