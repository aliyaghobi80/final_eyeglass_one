import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

extension DateTimeExtension on DateTime {
  DateTime get iranTime => add(const Duration(hours: 3, minutes: 30));

  String toIranianDate() {
    return iranTime.toPersianDateStr();
  }

  String toIranianTime() {
    return '${iranTime.hour.toString().padLeft(2, '0')}:${iranTime.minute.toString().padLeft(2, '0')}';
  }

  String toIranianDateTime() {
    return '${toIranianDate()} ساعت ${toIranianTime()}';
  }
}

extension TextExtension on Text {
  Directionality rtl() {
    return Directionality(textDirection: TextDirection.rtl, child: this);
  }

  Directionality ltr() {
    return Directionality(textDirection: TextDirection.ltr, child: this);
  }
}
