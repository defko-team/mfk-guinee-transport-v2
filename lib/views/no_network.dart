import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'dart:io';

class NoNetwork extends StatelessWidget {
  final String pageToGo;

  const NoNetwork({Key? key, required this.pageToGo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: Image.asset('assets/images/no-connection.gif'),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 7,
                vertical: MediaQuery.of(context).size.height / 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Ooops! 😓",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 54,
                ),
                Text(
                  "Aucune connexion internet n'a été détectée. Vérifiez votre connexion ou réessayez.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 51,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                MaterialButton(
                  onPressed: () async {
                    try {
                      final result = await InternetAddress.lookup('www.google.com');
                      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                        Navigator.pushReplacementNamed(context, pageToGo);
                      }
                    } on SocketException catch (_) {}
                  },
                  height: MediaQuery.of(context).size.height / 22,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: AppColors.green,
                  child: Text(
                    "Reessayer !",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
