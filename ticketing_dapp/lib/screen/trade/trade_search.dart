import 'package:flutter/material.dart';

class TradeSearch extends StatefulWidget {
  static const String id = 'trade_search';

  @override
  _TradeSearchState createState() => _TradeSearchState();
}

class _TradeSearchState extends State<TradeSearch> {
  Widget _bodyWidget() {
    return SafeArea(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
              ),
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.all(8.0),
              child: Material(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0xffff6f61),
                        width: 1.5,
                      ),
                    ),
                    hintText: "'검색'",
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
              ),
            ),
          ),
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
