import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/views/otp_verification.dart';
import 'package:mfk_guinee_transport/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  PhoneNumber _initialNumber = PhoneNumber(isoCode: 'GN');
  bool _isLoading = false;
  String? _fullPhoneNumber; // To store the complete phone number including the country code

  final AuthService _authService = AuthService();

  void _registerUser() async {
    if (_isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez entrer un numéro de téléphone valide')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Step 1: Send OTP and get the verification ID
        String? verificationId = await _authService.sendOtp(_fullPhoneNumber!);

        if (verificationId != null) {
          // Step 2: Navigate to OTP Verification Page with isRegistration flag set to true
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerification(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                phoneNumber: _fullPhoneNumber!,
                verificationId: verificationId,
                isRegistration: true, // Pass the isRegistration flag as true
              ),
            ),
          );
        } else {
          throw Exception('Failed to obtain verification ID');
        }
      } catch (e) {
        // Handle other exceptions (including cases where the user already exists or OTP verification fails)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://ouch-cdn2.icons8.com/n9XQxiCMz0_zpnfg9oldMbtSsG7X6NwZi_kLccbLOKw/rs:fit:392:392/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNDMv/MGE2N2YwYzMtMjQw/NC00MTFjLWE2MTct/ZDk5MTNiY2IzNGY0/LnN2Zw.png',
                  fit: BoxFit.cover,
                  width: 280,
                ),
                SizedBox(height: 50),
                FadeInDown(
                  child: Text(
                    'INSCRIPTION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                FadeInDown(
                  delay: Duration(milliseconds: 200),
                  child: TextFormField(
                    controller: _firstNameController,
                    validator: (value) =>
                        value!.isEmpty ? "Veuillez entrer un prénom" : null,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      hintText: 'Entrez votre prénom',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 58,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.height / 58,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                FadeInDown(
                  delay: Duration(milliseconds: 300),
                  child: TextFormField(
                    controller: _lastNameController,
                    validator: (value) =>
                        value!.isEmpty ? "Veuillez entrer un nom" : null,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      hintText: 'Entrez votre nom',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 58,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.height / 58,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                FadeInDown(
                  delay: Duration(milliseconds: 400),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        _fullPhoneNumber = number.phoneNumber; // Get the full phone number with country code
                      });
                    },
                    validator: (value) =>
                        value!.isEmpty ? "Veuillez entrer un numéro de téléphone" : null,
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      showFlags: true,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: AppColors.black),
                    textFieldController: _phoneNumberController,
                    formatInput: false,
                    maxLength: 9,
                    initialValue: _initialNumber,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    cursorColor: AppColors.black,
                    inputDecoration: InputDecoration(
                      labelText: 'Téléphone',
                      hintText: 'Entrez votre numéro de téléphone',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 58,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.height / 58,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSaved: (PhoneNumber number) {
                    },
                  ),
                ),
                SizedBox(height: 75),
                FadeInDown(
                  delay: Duration(milliseconds: 500),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    onPressed: _registerUser,
                    color: AppColors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    child: _isLoading
                        ? Container(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              backgroundColor: AppColors.green,
                              color: AppColors.green,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "S'inscrire",
                            style: TextStyle(color: AppColors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
