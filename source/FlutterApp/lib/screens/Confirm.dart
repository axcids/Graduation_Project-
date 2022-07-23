import 'package:flutter/material.dart';
import 'package:online_check_in/helpers/WidgetHelper.dart';
import 'package:online_check_in/helpers/api_helper.dart';
import 'package:online_check_in/screens/Settings.dart';

class ConfirmScreen extends StatefulWidget {
  final Map reservation;
  const ConfirmScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  ConfirmScreenState createState() {
    return ConfirmScreenState();
  }
}

class ConfirmScreenState extends State<ConfirmScreen> {
  bool _havePassportImage = true;
  Map _profile = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    Map reservation = widget.reservation;
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: _profile.isEmpty
            ? Container()
            : !_havePassportImage
                ? Center(
                    child: Column(
                      children: [
                        Container(height: 20),
                        const Text(
                          "You can't confirm this checkout until you upload an image for your passport, please upload one.",
                        ),
                        Container(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: MaterialButton(
                              color: Colors.blue[800],
                              onPressed: _toEditProfile,
                              child: const Text(
                                "Edit Profile",
                                style: TextStyle(color: Colors.white),
                              ),
                            ))
                          ],
                        )
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      Container(height: 20),
                      Center(
                        child: Text(
                          _calculateBill(reservation),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      Container(height: 20),
                      _billRow(
                        'Room',
                        reservation['room_info']['number'],
                        Colors.black,
                      ),
                      _billRow(
                        'Floor',
                        reservation['room_info']['floor'],
                        Colors.blue,
                      ),
                      _billRow(
                        'Nights',
                        reservation['nights'],
                        Colors.black54,
                      ),
                      _billRow(
                        'Adults',
                        reservation['adults'],
                        Colors.brown,
                      ),
                      _billRow(
                        'Children',
                        reservation['children'],
                        Colors.brown,
                      ),
                      _billRow(
                        'Rate',
                        reservation['room_info']['rate'].toString() + ' SAR',
                        Colors.green[800],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Terms",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "\nBy checking out you are accepting on the following terms: ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 145, 26, 18),
                              ),
                            ),
                            Container(height: 10),
                            _term("Term 1"),
                            _term("Term 2"),
                            _term("Term 3"),
                            Container(height: 10),
                            const Text(
                              "Passport Image",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Container(height: 10),
                            Image.network(
                              APIHelper.apiURL +
                                  '/' +
                                  _profile['profile']['passport_img']
                                      .toString(),
                              errorBuilder: ((context, error, stackTrace) {
                                return const Text(
                                  "Couldn't fetch image.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                );
                              }),
                            ),
                            Container(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    child: const Text(
                                      "CONFIRM",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      _confirmCheckOut(reservation['id']);
                                    },
                                    color: const Color.fromARGB(255, 87, 10, 4),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _billRow(String label, dynamic value, Color? color) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          child: Text(label),
        ),
        Expanded(
            child: Container(
          height: 0.5,
          color: Colors.black,
        )),
        Container(
          alignment: Alignment.center,
          width: 120,
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            value.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _term(String term) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Container(width: 5),
        Text(term),
      ],
    );
  }

  _toEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((value) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    APIHelper.getProfile().then((profile) {
      setState(() {
        _profile = profile;
        _havePassportImage = profile['profile']['passport_img'] != '' &&
            profile['profile']['passport_img'] != null;
      });
    });
  }

  Future<void> _confirmCheckOut(int id) async {
    APIHelper.checkOut(id).then((value) {
      WidgetHelper.showAlert(
          context, "Checked-out", 'You successfully checked-out', onOK: () {
        Navigator.pop(context);
      });
    });
  }

  String _calculateBill(reservation) {
    int nights = reservation['nights'];
    double rate = reservation['room_info']['rate'].toDouble();
    return (nights * rate).toString() + " SAR";
  }
}
