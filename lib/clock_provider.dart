import 'package:flutter/material.dart';

class ClockProvider with ChangeNotifier {
  int _hour = DateTime.now().hour;
  int _minute = DateTime.now().minute;
  int _second = DateTime.now().second;

  ///coordinates for seconds minutes and hours
  List<Offset> _secondsCoordinate = List(60);
  List<Offset> _minutesCoordinate = List(60);
  List<Offset> _hoursCoordinate = List(12);

  get hour => _hour;
  get minute => _minute;
  get second => _second;

  ///getters for coordinates
  get secondsCoordinate => _secondsCoordinate;
  get minutesCoordinate => _minutesCoordinate;
  get hoursCoordinate => _hoursCoordinate;

  set setHour(int hour) {
    this._hour = hour;
    notifyListeners();
  }

  set setMinute(int minute) {
    this._minute = minute;
    notifyListeners();
  }

  set setSecond(int second) {
    this._second = second;
    notifyListeners();
  }

  set setSecondsCoordinate(List<Offset> coordinate) {
    _secondsCoordinate = coordinate;
    notifyListeners();
  }

  set setMinutesCoordinate(List<Offset> coordinate) {
    _minutesCoordinate = coordinate;
    notifyListeners();
  }

  set setHoursCoordinate(List<Offset> coordinate) {
    _hoursCoordinate = coordinate;
    notifyListeners();
  }
}
