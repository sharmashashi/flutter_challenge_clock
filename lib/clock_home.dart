import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_challenge_clock/clock_provider.dart';
import 'package:provider/provider.dart';

class ClockHome extends StatelessWidget {
  double percent(double fullDimension, percentage) =>
      fullDimension * percentage / 100;
  final List<Color> gradientColors = [
    Colors.black,
    Colors.black87,
    Colors.black54
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight, screenWidth;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: Container(),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: AspectRatio(
          aspectRatio: 5 / 3,
          child: Stack(
            children: <Widget>[
              ///custom paint
              Container(
                height: screenHeight,
                width: screenWidth,
                child: ChangeNotifierProvider<ClockProvider>(
                  builder: (context) => ClockProvider(),
                  child: Builder(builder: (BuildContext context) {
                    ClockProvider _clockProvider =
                        Provider.of<ClockProvider>(context);
                    Future.delayed(Duration(seconds: 1)).then((_) {
                      _clockProvider.setSecond = DateTime.now().second;
                      _clockProvider.setMinute = DateTime.now().minute;
                      int hour = DateTime.now().hour;
                      if (hour > 12)
                        hour = hour - 12;
                      else if (hour == 0) hour = 12;
                      _clockProvider.setHour = hour;
                    });

                    return CustomPaint(
                      // size: MediaQuery.of(context).size,
                      painter: ClockPainter(
                          clockProvider: _clockProvider,
                          hour: _clockProvider.hour,
                          minute: _clockProvider.minute,
                          second: _clockProvider.second),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final ClockProvider clockProvider;

  int hour, minute, second;
  ClockPainter({this.hour, this.minute, this.second, this.clockProvider});

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    ///to calculate coordinates for hour
    List<Offset> hourCoordinates = List(13);

    ///analog coordinates of hours in each minute
    Offset analogHourCoordinate;

    analogHourCoordinate = Offset(30, 30);

    ///to calculate coordinate for seconds
    List<Offset> secondCoordinates = List(60);

    ///for rectangular border on 4 side of clock
    for (double i = 0; i <= 20; i = i + 0.1) {
      Paint borderLinePaint = Paint()
        ..color = Color.fromRGBO(47, 47, 49, i > 0.5 ? i / (35 - i) : 1);

      canvas.drawLine(
          Offset(i, i), Offset(i, size.height - i), borderLinePaint);
      canvas.drawLine(Offset(i, i), Offset(size.width - i, i), borderLinePaint);
      canvas.drawLine(Offset(size.width - i, i),
          Offset(size.width - i, size.height - i), borderLinePaint);
      canvas.drawLine(Offset(i, size.height - i),
          Offset(size.width - i, size.height - i), borderLinePaint);
    }

    for (int i = 1; i <= 12; i++) {
      if (i > 9) {
        hourCoordinates[i] =
            Offset(30 + ((i - 10) * (size.width - 60) / 4), 30);
      } else if (i < 3) {
        hourCoordinates[i] = Offset(
            30 + (size.width - 60) / 2 + (i) * (size.width - 60) / 4, 30);
      } else if (i < 9 && i > 5) {
        hourCoordinates[i] =
            Offset(30 + ((8 - i) * (size.width - 60) / 4), size.height - 30);
      } else if (i < 6 && i > 3) {
        hourCoordinates[i] = Offset(
            30 + (size.width - 60) / 2 + (6 - i) * (size.width - 60) / 4,
            size.height - 30);
      } else if (i == 9) {
        hourCoordinates[i] = Offset(30, size.height / 2);
      } else if (i == 3) {
        hourCoordinates[i] = Offset(size.width - 30, size.height / 2);
      }
    }

    Future.delayed(Duration(milliseconds: 0)).then((_) {
      clockProvider.setHoursCoordinate = hourCoordinates;
    });

    if (hour >= 10 || hour == 1) {
      analogHourCoordinate = clockProvider.hoursCoordinate[hour] +
          Offset(minute * (size.width - 60) / 240, 0);
    } else if (hour < 8 && hour > 3) {
      analogHourCoordinate = clockProvider.hoursCoordinate[hour] -
          Offset(minute * (size.width - 60) / 240, 0);
    } else if (hour >= 8 && hour < 10) {
      analogHourCoordinate = clockProvider.hoursCoordinate[hour] -
          Offset(0, minute * (size.height - 60) / 120);
    } else if (hour >= 2 && hour < 4) {
      if (clockProvider.hoursCoordinate[hour] != null)
        analogHourCoordinate = clockProvider.hoursCoordinate[hour] +
            Offset(0, minute * (size.height - 60) / 120);
    }

    for (int i = 0; i < 60; i++) {
      if (i >= 50) {
        secondCoordinates[i] =
            Offset(30 + ((i - 50) * (size.width - 60) / 20), 30);
      } else if (i <= 10) {
        secondCoordinates[i] = Offset(
            30 + (size.width - 60) / 2 + (i) * (size.width - 60) / 20, 30);
      } else if (i <= 40 && i >= 20) {
        secondCoordinates[i] =
            Offset(30 + ((40 - i) * (size.width - 60) / 20), size.height - 30);
      } else if (i > 10 && i < 20) {
        secondCoordinates[i] =
            Offset(size.width - 30, 30 + (i - 10) * (size.height - 60) / 10);
      } else {
        secondCoordinates[i] =
            Offset(30, 30 + (50 - i) * (size.height - 60) / 10);
      }
    }
    Future.delayed(Duration(milliseconds: 0)).then((_) {
      clockProvider.setSecondsCoordinate = secondCoordinates;
      clockProvider.setMinutesCoordinate = secondCoordinates;
    });

    ///end coordinates of second,minute and hour
    ///which is shorter than full offset to points.
    ///fount out by using section formula with ratio
    ///m:1=3:1
    double m1 = 5, m2 = 7;

    ///for hour
    Offset hourEndCoordinate = Offset(
        (m1 * analogHourCoordinate.dx + m2 * size.width / 2) / (m1 + m2),
        (m1 * analogHourCoordinate.dy + m2 * size.height / 2) / (m1 + m2));

    ///for minute
    m1 = 5;
    m2 = 2;

    Offset minuteEndCoordinate;
    if (clockProvider.minutesCoordinate[minute] != null)
      minuteEndCoordinate = Offset(
          (m1 * clockProvider.minutesCoordinate[minute].dx +
                  m2 * size.width / 2) /
              (m1 + m2),
          (m1 * clockProvider.minutesCoordinate[minute].dy +
                  m2 * size.height / 2) /
              (m1 + m2));

    ///for second
    m1 = 5;
    m2 = 1;
    Offset secondEndCoordinate;
    if (clockProvider.secondsCoordinate[second] != null)
      secondEndCoordinate = Offset(
          (m1 * clockProvider.secondsCoordinate[second].dx +
                  m2 * size.width / 2) /
              (m1 + m2),
          (m1 * clockProvider.secondsCoordinate[second].dy +
                  m2 * size.height / 2) /
              (m1 + m2));

    ///paint  second dots
    List<Offset> secondTowardCenterCoordinate = List(60);
    Paint secondDotsPaint = Paint()
      ..color = Color.fromRGBO(15, 157, 88, 1)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    m1 = 1;
    m2 = 25;
    for (int i = 0; i < 60; i++) {
      // Rect rect = Rect.fromCircle(center: secondCoordinates[i], radius: 3);
      // canvas.drawArc(rect, 0, 2 * pi, true, secondDotsPaint);
      secondTowardCenterCoordinate[i] = Offset(
          (m1 * size.width / 2 + m2 * secondCoordinates[i].dx) / (m1 + m2),
          (m1 * size.height / 2 + m2 * secondCoordinates[i].dy) / (m1 + m2));
      canvas.drawLine(secondCoordinates[i], secondTowardCenterCoordinate[i],
          secondDotsPaint);
    }

    canvas.drawCircle(secondTowardCenterCoordinate[second], 2.5,
        Paint()..color = Color.fromRGBO(219, 68, 55, 1));
    canvas.drawCircle(secondTowardCenterCoordinate[minute], 3,
        Paint()..color = Color.fromRGBO(15, 157, 88, 1));

    ///paint hour dots
    List<Offset> hourTowardCenterCoordinate = List(13);
    Paint hourDotsPaint = Paint()
      ..color = Color.fromRGBO(244, 160, 0, 1)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    m1 = 1;
    m2 = 14;
    for (int i = 1; i <= 12; i++) {
      // Rect rect = Rect.fromCircle(center: hourCoordinates[i], radius: 7);
      // canvas.drawArc(rect, 0, 2 * pi, true, hourDotsPaint);
      hourTowardCenterCoordinate[i] = Offset(
          (m1 * size.width / 2 + m2 * hourCoordinates[i].dx) / (m1 + m2),
          (m1 * size.height / 2 + m2 * hourCoordinates[i].dy) / (m1 + m2));
      canvas.drawLine(
          hourCoordinates[i], hourTowardCenterCoordinate[i], hourDotsPaint);
    }
    canvas.drawCircle(hourTowardCenterCoordinate[hour], 4.5,
        Paint()..color = Color.fromRGBO(244, 160, 0, 1));

    ///hour
    Paint hourPaint = Paint()
      ..color = Color.fromRGBO(244, 160, 0, 1)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas.drawLine(
        hourEndCoordinate, Offset(size.width / 2, size.height / 2), hourPaint);

    ///minute
    Paint minutePaint = Paint()
      ..color = Color.fromRGBO(15, 157, 88, 1)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    if (minuteEndCoordinate != null)
      canvas.drawLine(minuteEndCoordinate,
          Offset(size.width / 2, size.height / 2), minutePaint);

    ///second
    Paint secondPaint = Paint()
      ..color = Color.fromRGBO(219, 68, 55, 1)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    if (secondEndCoordinate != null)
      canvas.drawLine(secondEndCoordinate,
          Offset(size.width / 2, size.height / 2), secondPaint);

    ///center of clock
    for (double i = 0; i <= 10; i = i + 1) {
      Paint centerClockPaint = Paint()
        ..color = Color.fromRGBO(219, 68, 55, i * i * i);
      Rect centerRect = Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: i + 3);
      canvas.drawArc(centerRect, 0, 2 * pi, true, centerClockPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
