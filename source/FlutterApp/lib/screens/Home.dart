import 'package:flutter/material.dart';
import 'package:online_check_in/helpers/WidgetHelper.dart';
import 'package:online_check_in/helpers/api_helper.dart';
import 'package:online_check_in/screens/Confirm.dart';
import 'package:online_check_in/screens/QRCode.dart';
import 'package:online_check_in/screens/Settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  List<Map> _reservations = [
    // {
    //   "id": 1,
    //   "arrival_date": "2015-5-5",
    //   "departure_date": "2015-5-5",
    //   "nights": 1,
    //   "adults": 2,
    //   "children": 3,
    //   "status": "CHECKED-IN",
    //   "room_info": {
    //     "floor": 1,
    //     "number": "003",
    //     "rate": 555,
    //   }
    // },
  ];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reservations"),
        actions: [
          IconButton(
            onPressed: _toEditProfile,
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: _myReservationsList(_reservations),
    );
  }

  Widget _myReservationsList(List<Map> reservations) {
    if (reservations.isEmpty) {
      return RefreshIndicator(
          child: ListView(
            children: <Widget>[
              Container(height: 200),
              const Center(
                child: Text("No reservations avilable."),
              ),
            ],
          ),
          onRefresh: _loadReservations);
    }
    return RefreshIndicator(
        child: ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (BuildContext context, int index) {
            Map reservation = reservations[index];
            String rArrival = reservation['arrival_date'].toString();
            String rQRCode = reservation['qrcode'].toString();
            String rQRCodeImg = reservation['qrcode_img'].toString();
            String rDeparture = reservation['departure_date'].toString();
            String rStatus = reservation['status'].toString();
            String rAdults = reservation['adults'].toString();
            String rChildren = reservation['children'].toString();
            String rNights = reservation['nights'].toString();
            String roomNumber = reservation['room_info']['number'].toString();
            String roomFloor = reservation['room_info']['floor'].toString();
            String roomRate = reservation['room_info']['rate'].toString();
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ROOM - " + roomNumber + " | $rArrival / $rDeparture",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _cardColumn(
                            "Floor",
                            roomFloor,
                            Colors.blue,
                            Colors.white,
                          ),
                          _cardColumn(
                            "Nights",
                            rNights,
                            Colors.black,
                            Colors.white,
                          ),
                          _cardColumn(
                            "Adults",
                            rAdults,
                            Colors.brown,
                            Colors.white,
                          ),
                          _cardColumn(
                            "Children",
                            rChildren,
                            Colors.brown,
                            Colors.white,
                          ),
                          _cardColumn(
                            "Rate",
                            roomRate.toString() + " SAR",
                            Colors.green[800],
                            Colors.white,
                          ),
                        ],
                      ),
                      Container(height: 10),
                      rStatus == "CHECKED_IN"
                          ? Row(
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    color: Colors.teal,
                                    onPressed: () =>
                                        _showQRCode(rQRCode, rQRCodeImg),
                                    child: const Text(
                                      "QR-CODE",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              color: rStatus == "SENT"
                                  ? const Color.fromARGB(255, 63, 90, 64)
                                  : rStatus == "CHECKED_IN"
                                      ? const Color.fromARGB(255, 146, 10, 0)
                                      : const Color.fromARGB(255, 32, 32, 32),
                              onPressed: () => _handleReservation(reservation),
                              child: Text(
                                rStatus == 'SENT'
                                    ? 'CHECK-IN'
                                    : rStatus == 'PENDING'
                                        ? 'PENDING'
                                        : 'CHECK-OUT',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(
                  height: 5.0,
                  color: Colors.grey,
                ),
              ],
            );
          },
        ),
        onRefresh: _loadReservations);
  }

  Widget _cardColumn(title, value, bgColor, textColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: textColor)),
          Container(height: 5),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  _toEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Future<void> _loadReservations() async {
    APIHelper.getReservations().then((reservationsList) {
      setState(() {
        _reservations = reservationsList;
      });
    });
  }

  _handleReservation(Map reservation) {
    String rStatus = reservation['status'];
    if (rStatus == 'SENT') {
      APIHelper.getProfile().then((user) {
        if (user['profile']['passport_img'].toString() == '' &&
            user['profile']['passport_img'] != null) {
          WidgetHelper.showAlert(context, "Unable To Check In",
              'You must have a pasport image uploaded to check in', onOK: () {
            _toEditProfile();
          });
        } else {
          _checkIn(reservation['id']);
        }
      });
    }
    if (rStatus == 'CHECKED_IN') {
      _checkOut(reservation);
    }
  }

  _showQRCode(String rQRCode, String rQRCodeImg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScreen(
          rQRCode: rQRCode,
          rQRCodeImg: rQRCodeImg,
        ),
      ),
    );
  }

  Future<void> _checkIn(int id) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Your request is pending, we will approve it as soon as possible',
        ),
      ),
    );
    APIHelper.checkIn(id).then((value) {
      _loadReservations();
    });
  }

  _checkOut(Map reservation) {
    WidgetHelper.confirmAlert(
        context, "Confirm", 'Are you sure you want to checkout?',
        onConfirm: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmScreen(
            reservation: reservation,
          ),
        ),
      ).then((value) {
        _loadReservations();
      });
    });
  }
}
