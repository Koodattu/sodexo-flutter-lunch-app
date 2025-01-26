import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

/// A simple ChangeNotifier that manages a random WordPair.
/// (Used mostly to show an example of Provider usage.)
class LunchAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}
