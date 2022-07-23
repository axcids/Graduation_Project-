import 'package:flutter/material.dart';
import 'package:online_check_in/helpers/api_helper.dart';

class QRCodeScreen extends StatefulWidget {
  final String rQRCode;
  final String rQRCodeImg;
  const QRCodeScreen(
      {Key? key, required this.rQRCode, required this.rQRCodeImg})
      : super(key: key);

  @override
  QRCodeScreenState createState() {
    return QRCodeScreenState();
  }
}

class QRCodeScreenState extends State<QRCodeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String rQRCode = widget.rQRCode;
    String rQRCodeImg = widget.rQRCodeImg;
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text("QRCode"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(5),
          child: Center(
            child: Column(
              children: [
                Container(height: 50),
                const Text(
                  "Your room key",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Container(height: 20),
                Image.network(
                  APIHelper.apiURL + "/" + rQRCodeImg,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "Couldn't load QRCode.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    );
                  },
                  headers: const {"Keep-Alive": "timeout=15, max=1000"},
                ),
                Container(height: 20),
                Text(rQRCode)
              ],
            ),
          )),
    );
  }
}
