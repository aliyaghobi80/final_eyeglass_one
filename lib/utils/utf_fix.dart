import 'dart:convert';

String decodeUTF8(String encodedString) {
  return utf8.decode(encodedString.runes.toList());
}