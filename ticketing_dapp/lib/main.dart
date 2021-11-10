import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketing_dapp/screen/entrace.dart';
import 'package:ticketing_dapp/screen/seller/register/registration_concert.dart';
import 'package:ticketing_dapp/screen/info_concert.dart';
import 'package:ticketing_dapp/screen/main_page.dart';
import 'package:ticketing_dapp/screen/more.dart';
import 'package:ticketing_dapp/screen/login_screen.dart';
import 'package:ticketing_dapp/screen/my_like.dart';
import 'package:ticketing_dapp/screen/seller/seller_home.dart';
import 'package:ticketing_dapp/screen/seller/seller_main_screen.dart';
import 'package:ticketing_dapp/screen/signup_screen.dart';
import 'package:ticketing_dapp/screen/trade/list_my_tickets.dart';
import 'package:ticketing_dapp/screen/trade/trade_screen.dart';
import 'package:ticketing_dapp/screen/trade/trade_search.dart';
import 'package:ticketing_dapp/screen/trade/trade_transaction.dart';

import 'controller/contract_linking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if(_error) {
      return Center(
        child: Container(
          child: Text('Something went wrong'),
        ),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Center(
        child: Container(
          child: Text('Loading'),
        ),
      );
    }

    return ChangeNotifierProvider<ContractLinking>(
      create: (_) => ContractLinking(),
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.white,
          textTheme: TextTheme(
            bodyText1: TextStyle(
              color: Colors.grey,
            ),
            bodyText2: TextStyle(
              color: Colors.black,
            ),
          ),),
        initialRoute: LogInScreen.id,
        routes: {
          LogInScreen.id: (context) => LogInScreen(),
          SignUpScreen.id: (context) => SignUpScreen(),
          TradeScreen.id: (context) => TradeScreen(),
          SellerMainScreen.id: (context) => SellerMainScreen(),
          More.id: (context) => More(),
          MyLike.id: (context) => MyLike(),
          TradeTransaction.id: (context) => TradeTransaction(),
          MainPage.id: (context) => MainPage(),
          RegistrationConcert.id: (context) => RegistrationConcert(),
          TradeSearch.id: (context) => TradeSearch(),
          ListofMyTickets.id: (context) => ListofMyTickets(),
          Entrance.id: (context) => Entrance(),
          SellerHome.id: (context) => SellerHome(),
        },
      ),
    );
  }
}
