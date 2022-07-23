import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_check_in/helpers/WidgetHelper.dart';
import 'package:online_check_in/helpers/api_helper.dart';
import 'package:online_check_in/screens/SingIn.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() {
    return SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  Map _profile = {};

  final fnameCtrl = TextEditingController();
  final lnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passportIdCtrl = TextEditingController();

  final TextStyle headerStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        actions: [
          IconButton(
            onPressed: _signout,
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: _profile['username'] == null
          ? null
          : ListView(children: [
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
                      Container(height: 10),
                      Row(
                        children: [
                          const Text("Passport Image"),
                          Expanded(
                            child: Container(),
                          ),
                          TextButton(
                            onPressed: _changePassportImg,
                            child: const Text(
                              "UPLOAD IMAGE",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: Image.network(
                          APIHelper.apiURL +
                              "/" +
                              _profile['profile']['passport_img'],
                          width: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              "No passport Image, upload one.",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            );
                          },
                          headers: const {"Keep-Alive": "timeout=15, max=1000"},
                        ),
                      ),
                      Container(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("User & Login Info", style: headerStyle),
                      ),
                      TextFormField(
                        enabled: false,
                        initialValue: _profile['phone'].toString(),
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
                        enabled: false,
                        initialValue: _profile['username'].toString(),
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
                      Container(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              color: Colors.black,
                              textColor: Colors.white,
                              child: const Text("SAVE-CHANGES"),
                              onPressed: _save,
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      APIHelper.editProfile(
        fnameCtrl.text,
        lnameCtrl.text,
        emailCtrl.text,
        passportIdCtrl.text,
      ).then((resp) {
        if (resp['status']) {
          WidgetHelper.showAlert(
            context,
            'Success',
            "Changes successfully saved!",
          );
        }
      });
    }
  }

  void _loadProfile() async {
    APIHelper.getProfile().then((profile) {
      setState(() {
        _profile = profile;
        fnameCtrl.text = profile['profile']['first_name'].toString();
        lnameCtrl.text = profile['profile']['last_name'].toString();
        emailCtrl.text = profile['profile']['email'].toString();
        passportIdCtrl.text = profile['profile']['passport_id'].toString();
      });
    });
  }

  void _toSingin() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SinginScreen()),
    );
  }

  Future<void> _changePassportImg() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    APIHelper.updatePassportImage(image).then((value) {
      _loadProfile();
    });
  }

  void _signout() {
    _toSingin();
  }
}
