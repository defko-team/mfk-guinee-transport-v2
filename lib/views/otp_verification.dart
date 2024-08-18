import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';

class OtpVerification extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const OtpVerification({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  bool _isResendAgain = false;
  bool _isVerified = false;
  bool _isLoading = false;

  String _code = '';
  Timer? _timer;
  int _start = 60;
  int _currentIndex = 0;

  final AuthService _authService = AuthService();

  void resend() {
    setState(() {
      _isResendAgain = true;
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (mounted) {
        setState(() {
          if (_start == 0) {
            _start = 60;
            _isResendAgain = false;
            timer.cancel();
          } else {
            _start--;
          }
        });
      }
    });

    // Resend the OTP
    _authService.sendOtp(widget.phoneNumber);
  }

  void verify() async {
    if (_code.length < 4) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify the OTP using the AuthService
      await _authService.verifyOtpAndRegisterUser(
        otp: _code,
        prenom: widget.firstName,
        nom: widget.lastName,
        telephone: widget.phoneNumber,
      );

      setState(() {
        _isLoading = false;
        _isVerified = true;
      });

      // Navigate to the desired page after successful verification
      Navigator.pushReplacementNamed(context, '/desiredPage');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Handle verification failure, maybe show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex++;
          if (_currentIndex == 3) {
            _currentIndex = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 250,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedOpacity(
                        opacity: _currentIndex == 0 ? 1 : 0,
                        duration: Duration(seconds: 1),
                        curve: Curves.linear,
                        child: Image.network(
                          'https://ouch-cdn2.icons8.com/eza3-Rq5rqbcGs4EkHTolm43ZXQPGH_R4GugNLGJzuo/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNjk3/L2YzMDAzMWUzLTcz/MjYtNDg0ZS05MzA3/LTNkYmQ0ZGQ0ODhj/MS5zdmc.png',
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedOpacity(
                        opacity: _currentIndex == 1 ? 1 : 0,
                        duration: Duration(seconds: 1),
                        curve: Curves.linear,
                        child: Image.network(
                          'https://ouch-cdn2.icons8.com/pi1hTsTcrgVklEBNOJe2TLKO2LhU6OlMoub6FCRCQ5M/rs:fit:784:666/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvMzAv/MzA3NzBlMGUtZTgx/YS00MTZkLWI0ZTYt/NDU1MWEzNjk4MTlh/LnN2Zw.png',
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedOpacity(
                        opacity: _currentIndex == 2 ? 1 : 0,
                        duration: Duration(seconds: 1),
                        curve: Curves.linear,
                        child: Image.network(
                          'https://ouch-cdn2.icons8.com/ElwUPINwMmnzk4s2_9O31AWJhH-eRHnP9z8rHUSS5JQ/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNzkw/Lzg2NDVlNDllLTcx/ZDItNDM1NC04YjM5/LWI0MjZkZWI4M2Zk/MS5zdmc.png',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              FadeInDown(
                duration: Duration(milliseconds: 500),
                child: Text(
                  "Verification",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30),
              FadeInDown(
                delay: Duration(milliseconds: 500),
                duration: Duration(milliseconds: 500),
                child: Text(
                  "Veuillez saisir le code à 6 chiffres envoyé à \n ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Verification Code Input
              FadeInDown(
                delay: Duration(milliseconds: 600),
                duration: Duration(milliseconds: 500),
                child: VerificationCode(
                  length: 6,
                  textStyle: TextStyle(fontSize: 20, color: Colors.black),
                  underlineColor: Colors.black,
                  keyboardType: TextInputType.number,
                  underlineUnfocusedColor: Colors.black,
                  onCompleted: (value) {
                    setState(() {
                      _code = value;
                    });
                  },
                  onEditing: (value) {},
                ),
              ),
              SizedBox(height: 20),
              FadeInDown(
                delay: Duration(milliseconds: 700),
                duration: Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Vous n'avez pas reçu l'OTP ?",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ),
                    SizedBox(width: 2), // Add space between the text and button
                    TextButton(
                      onPressed: () {
                        if (_isResendAgain) return;
                        resend();
                      },
                      child: Text(
                        _isResendAgain
                            ? "Réessayez dans $_start"
                            : "Renvoyer",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              FadeInDown(
                delay: Duration(milliseconds: 800),
                duration: Duration(milliseconds: 500),
                child: MaterialButton(
                  elevation: 0,
                  onPressed: _code.length < 6 ? null : verify,
                  color: Colors.orange.shade400,
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  child: _isLoading
                      ? Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            strokeWidth: 3,
                            color: Colors.black,
                          ),
                        )
                      : _isVerified
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 30,
                            )
                          : Text(
                              "Verifier",
                              style: TextStyle(color: Colors.white),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
