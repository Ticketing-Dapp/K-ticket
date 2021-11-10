import 'package:flutter/material.dart';

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  hintStyle: TextStyle(color: Colors.grey),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xffff6f61), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const Map<String, dynamic> kIconMap = {
  '콘서트': Icons.music_note_rounded,
  '스포츠': Icons.sports_baseball,
  '영화': Icons.movie_sharp,
  '전시/행사': Icons.photo,
};

enum kKindsOfUser { seller, buyer }
