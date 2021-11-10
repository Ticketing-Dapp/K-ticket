import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_dapp/constants.dart';
import 'package:ticketing_dapp/controller/auth.dart';
import 'package:ticketing_dapp/screen/seller/seller_main_screen.dart';
import 'package:ticketing_dapp/screen/signup_screen.dart';
import 'package:ticketing_dapp/screen/main_page.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LogInScreen extends StatefulWidget {
  static const String id = 'log_in_screen';

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool showSpinner = false;
  late String email;
  late String password;

  int _character = kKindsOfUser.seller.index;

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _logoWidget() {
    return Container(
      child: Image.asset('assets/images/ticket.jpg'),
      height: 120.0,
    );
  }

  Widget _emailWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 10.0),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          email = value;
        },
        decoration:
        kTextFieldDecoration.copyWith(hintText: 'Enter your Email'),
      ),
    );
  }

  Widget _passwordWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 20.0),
      child: TextField(
        obscureText: true,
        onChanged: (value) {
          password = value;
        },
        decoration: kTextFieldDecoration.copyWith(
          hintText: 'Enter your password',
        ),
      ),
    );
  }

  Widget _logInButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color(0xffff6f61),
        ),
        onPressed: () {
          setState(() {
            showSpinner = true;
          });
          signIn(email, password).then((value) {
            if (value == true) {
              User user = FirebaseAuth.instance.currentUser!;
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get()
                  .then((DocumentSnapshot ds) {
                Map<String, dynamic>? userInfo =
                ds.data() as Map<String, dynamic>;
                _character = userInfo['type'];
                if (_character == kKindsOfUser.buyer.index) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainPage(),
                    ),
                  );
                } else if (_character == kKindsOfUser.seller.index) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SellerMainScreen(),
                    ),
                  );
                }
              });
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Log In Error'),
                  content: Text('Check your email or password'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
            setState(() {
              showSpinner = false;
            });
          }, onError: (e) {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Log In Error'),
                content: Text('Check your email or password'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        },
        child: Text('Log In'),
      ),
    );
  }

  Widget _gotoSignUpWidget() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, SignUpScreen.id);
      },
      child: Text('Not registered? Sign Up'),
    );
  }

  Widget _bodyWidget() {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: CircularProgressIndicator(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _logoWidget(),
          _emailWidget(),
          _passwordWidget(),
          _logInButtonWidget(),
          _gotoSignUpWidget(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
