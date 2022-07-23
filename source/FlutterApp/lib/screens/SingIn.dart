import 'package:flutter/material.dart';
import 'package:online_check_in/helpers/WidgetHelper.dart';
import 'package:online_check_in/helpers/api_helper.dart';
import 'package:online_check_in/screens/Home.dart';
import 'package:online_check_in/screens/Signup.dart';

class SinginScreen extends StatefulWidget {
  const SinginScreen({Key? key}) : super(key: key);

  @override
  SinginScreenState createState() {
    return SinginScreenState();
  }
}

class SinginScreenState extends State<SinginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String _err = "";

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign-In"),
      ),
      body: ListView(children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Username",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your username.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password.';
                    }
                    return null;
                  },
                ),
                Container(height: 10),
                Text(_err,
                    style: const TextStyle(fontSize: 14, color: Colors.red)),
                Container(height: 10),
                TextButton(
                  onPressed: _toSingup,
                  child: const Text(
                    "SIGN-UP NEW ACCOUNT",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(height: 200),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        color: Colors.black,
                        textColor: Colors.white,
                        child: const Text("SIGN-IN"),
                        minWidth: 200,
                        onPressed: _signin,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  void _signin() {
    // Navigator.of(context).popUntil((route) => route.isFirst);
    if (_formKey.currentState!.validate()) {
      WidgetHelper.showLoadingAlert(context, "Signing-in", "Loading ...");
      APIHelper.login(usernameCtrl.text, passwordCtrl.text).then(
        (loggedIn) {
          Navigator.pop(context);
          if (loggedIn) {
            setState(() {
              _err = "";
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            setState(() {
              _err = "Invalid Credentials";
            });
          }
        },
      );
    }
  }

  void _toSingup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SingupScreen()),
    ).then(
      (value) {
        usernameCtrl.clear();
        passwordCtrl.clear();
      },
    );
  }
}
