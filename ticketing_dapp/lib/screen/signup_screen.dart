import 'package:flutter/material.dart';
import 'package:ticketing_dapp/constants.dart';
import 'package:ticketing_dapp/controller/auth.dart';
import 'package:ticketing_dapp/screen/main_page.dart';
import 'package:ticketing_dapp/screen/seller/seller_main_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const String id = 'sign_up_screen';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late String email;
  late String password;
  late String checkPassword;

  kKindsOfUser? _character = kKindsOfUser.seller;

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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 10.0),
          child: TextField(
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your password'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 20.0),
          child: TextField(
            obscureText: true,
            onChanged: (value) {
              checkPassword = value;
            },
            decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your password'),
          ),
        ),
      ],
    );
  }

  Widget _userTypeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: RadioListTile(
            title: const Text('Seller'),
            value: kKindsOfUser.seller,
            groupValue: _character,
            onChanged: (kKindsOfUser? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        Flexible(
          child: RadioListTile(
            title: const Text('Buyer'),
            value: kKindsOfUser.buyer,
            groupValue: _character,
            onChanged: (kKindsOfUser? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _signUpButtonWidget() {
    return ElevatedButton(
      onPressed: () {
        signUp(email, password, _character!.index).then((value) {
          // success sign up &
          // exception handling
          if (value == true) {
            if (_character == kKindsOfUser.seller) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SellerMainScreen(),
                ),
              );
            } else if (_character == kKindsOfUser.buyer) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MainPage(),
                ),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Sign Up Error'),
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
        });
      },
      child: Text('Sign Up'),
      style: ElevatedButton.styleFrom(
        primary: Color(0xffff6f61),
      ),
    );
  }

  Widget _bodyWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _logoWidget(),
          _emailWidget(),
          _passwordWidget(),
          _userTypeWidget(),
          _signUpButtonWidget(),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(),
    );
  }
}
