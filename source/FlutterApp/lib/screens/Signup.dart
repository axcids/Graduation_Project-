import 'package:flutter/material.dart';
import 'package:online_check_in/helpers/WidgetHelper.dart';
import 'package:online_check_in/helpers/api_helper.dart';

class SingupScreen extends StatefulWidget {
  const SingupScreen({Key? key}) : super(key: key);

  @override
  SingupScreenState createState() {
    return SingupScreenState();
  }
}

class SingupScreenState extends State<SingupScreen> {
  final _formKey = GlobalKey<FormState>();
  final fnameCtrl = TextEditingController();
  final lnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passportIdCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final TextStyle headerStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign-Up New Account"),
      ),
      body: ListView(children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Profile Info", style: headerStyle),
                ),
                TextFormField(
                  controller: fnameCtrl,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your first name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: lnameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your last name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Email (optional)",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    return null;
                  },
                ),
                TextFormField(
                  controller: passportIdCtrl,
                  decoration: const InputDecoration(
                    labelText: "Passport Id",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your passport id.';
                    }
                    return null;
                  },
                ),
                Container(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("User & Login Info", style: headerStyle),
                ),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your phone number.';
                    }
                    return null;
                  },
                ),
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
                Container(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        color: Colors.black,
                        textColor: Colors.white,
                        child: const Text("SIGN-UP"),
                        onPressed: _signup,
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

  void _signup() {
    if (_formKey.currentState!.validate()) {
      WidgetHelper.showLoadingAlert(context, "Loading", 'Signing-up...');
      APIHelper.signup(
        fnameCtrl.text,
        lnameCtrl.text,
        emailCtrl.text,
        passportIdCtrl.text,
        phoneCtrl.text,
        usernameCtrl.text,
        passwordCtrl.text,
      ).then((resp) {
        Navigator.pop(context);
        if (resp['status']) {
          WidgetHelper.showAlert(context, 'Success', "You can login now.",
              onOK: _toSingin);
        } else {
          WidgetHelper.showAlert(context, 'Unable To Signup', resp['msg']);
        }
      });
    }
  }

  void _toSingin() {
    Navigator.pop(context);
  }
}
