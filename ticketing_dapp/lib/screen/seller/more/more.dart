import 'package:flutter/material.dart';
import 'package:ticketing_dapp/controller/auth.dart';
import 'package:ticketing_dapp/screen/login_screen.dart';

class More extends StatelessWidget {
  static const String id = 'more';

  const More({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: InkWell(
          onTap: () {
            signOutUser().whenComplete(() => {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LogInScreen.id, (route) => false)
                });
          },
          child: Text('Log Out'),
        ),
      ),
    );
  }
}
