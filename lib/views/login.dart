import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController controller = TextEditingController();
  bool _isLoading = false;
  PhoneNumber _initialNumber = PhoneNumber(isoCode: 'GN');

  void _requestOtp() {
    setState(() {
      _isLoading = true;
    });

    // Simuler une attente pour une vraie logique de demande OTP
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Remplacer cette ligne par la navigation vers votre propre page de vérification OTP
      Navigator.push(context, MaterialPageRoute(builder: (context) => VerificationScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Utilisation de la couleur blanche définie
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.shade900),
                ),
              ),
              FadeInDown(
                delay: Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
                  child: Text(
                    'Entrez votre numéro de téléphone pour continuer. Nous vous enverrons un OTP pour vérification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ),
              SizedBox(height: 30),
              FadeInDown(
                delay: Duration(milliseconds: 400),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.white, // Utilisation de la couleur blanche définie
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.black.withOpacity(0.13)), // Couleur noire avec opacité
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey, // Utilisation de la couleur grise définie
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          print(number.phoneNumber);
                        },
                        onInputValidated: (bool value) {
                          print(value);
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          showFlags: true, // Pour afficher le drapeau
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: TextStyle(color: AppColors.black), // Utilisation de la couleur noire définie
                        textFieldController: controller,
                        formatInput: false,
                        maxLength: 9,
                        initialValue: _initialNumber, // Numéro initial avec le code de la Guinée
                        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                        cursorColor: AppColors.black, // Utilisation de la couleur noire définie
                        inputDecoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 15, left: 0),
                          border: InputBorder.none,
                          hintText: 'Numéro de téléphone',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                        onSaved: (PhoneNumber number) {
                          print('On Saved: $number');
                        },
                      ),
                      Positioned(
                        left: 90,
                        top: 8,
                        bottom: 8,
                        child: Container(
                          height: 40,
                          width: 1,
                          color: AppColors.black.withOpacity(0.13), // Couleur noire avec opacité
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 100),
              FadeInDown(
                delay: Duration(milliseconds: 600),
                child: MaterialButton(
                  minWidth: double.infinity,
                  onPressed: _requestOtp,
                  color: AppColors.green, // Utilisation de la couleur noire définie
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  child: _isLoading
                      ? Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: AppColors.green, // Utilisation de la couleur blanche définie
                            color: AppColors.green, // Utilisation de la couleur noire définie
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Demander le code",
                          style: TextStyle(color: AppColors.white), // Utilisation de la couleur blanche définie
                        ),
                ),
              ),
              SizedBox(height: 20),
              FadeInDown(
                delay: Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('J\'ai déja un compte ?', style: TextStyle(color: Colors.grey.shade700)),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text('Se connecter', style: TextStyle(color: AppColors.black)), // Utilisation de la couleur noire définie
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Utilisation de la couleur blanche définie
      body: Center(
        child: Text(
          'Verification Screen Placeholder',
          style: TextStyle(fontSize: 24, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
