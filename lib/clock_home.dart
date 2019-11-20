import 'dart:math';

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

  Widget bigDot = Container(
    height: 20,
    width: 20,
    decoration:
        BoxDecoration(color: Colors.deepPurple[900], shape: BoxShape.circle),
  );
  Widget smallDot = Container(
    height: 10,
    width: 10,
    decoration:
        BoxDecoration(color: Colors.deepPurple[900], shape: BoxShape.circle),
  );
  double screenHeight, screenWidth;

  List<Widget> bigDots = [];
  List<Widget> horizontalSmallDots = [];
  List<Widget> verticalSmallDots = [];

  @override
  Widget build(BuildContext context) {
    bigDots.clear();
    for (int i = 0; i < 3; i++) {
      bigDots.add(bigDot);
    }

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      builder: (context) => ClockProvider(),
      child: Builder(builder: (BuildContext context) {
        ClockProvider _clockProvider = Provider.of<ClockProvider>(context);
        Future.delayed(Duration(seconds: 1)).then((_) {
          _clockProvider.setSecond = DateTime.now().second;
          _clockProvider.setMinute = DateTime.now().minute;
          int hour = DateTime.now().hour;
          if (hour > 12)
            hour = hour - 12;
          else if (hour == 0) hour = 12;
          _clockProvider.setHour = hour;
        });

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
                    child: CustomPaint(
                      // size: MediaQuery.of(context).size,
                      painter: ClockPainter(
                          clockProvider: _clockProvider,
                          hour: _clockProvider.hour,
                          minute: _clockProvider.minute,
                          second: _clockProvider.second),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ClockPainter extends CustomPainter {
  final clockProvider;

  int hour, minute, second;
  ClockPainter({this.hour, this.minute, this.second, this.clockProvider});

  @override
  void paint(Canvas canvas, Size size) {
    ///for rectangular border on 4 side of clock
    for (double i = 0; i <= 20; i = i + 0.1) {
      Paint borderLinePaint = Paint()
        ..color = Color.fromRGBO(0, 0, 0, i > 0.5 ? i / (35 - i) : 1);

      canvas.drawLine(
          Offset(i, i), Offset(i, size.height - i), borderLinePaint);
      canvas.drawLine(Offset(i, i), Offset(size.width - i, i), borderLinePaint);
      canvas.drawLine(Offset(size.width - i, i),
          Offset(size.width - i, size.height - i), borderLinePaint);
      canvas.drawLine(Offset(i, size.height - i),
          Offset(size.width - i, size.height - i), borderLinePaint);
    }

    ///to calculate coordinates for hour
    List<Offset> hourCoordinates = List(13);

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
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      clockProvider.setHoursCoordinate = hourCoordinates;
    });

    ///analog coordinates of hours in each minute
    Offset analogHourCoordinate;

    analogHourCoordinate = Offset(30, 30);

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
      analogHourCoordinate = clockProvider.hoursCoordinate[hour] +
          Offset(0, minute * (size.height - 60) / 120);
    }

    ///to calculate coordinate for seconds
    List<Offset> secondCoordinates = List(60);
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
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      clockProvider.setSecondsCoordinate = secondCoordinates;
      clockProvider.setMinutesCoordinate = secondCoordinates;
    });

    ///paint  second dots
    Paint secondDotsPaint = Paint()..color = Colors.blue[900];
    for (int i = 0; i < 60; i++) {
      Rect rect = Rect.fromCircle(center: secondCoordinates[i], radius: 3);
      canvas.drawArc(rect, 0, 2 * pi, true, secondDotsPaint);
    }

    ///paint hour dots
    Paint hourDotsPaint = Paint()..color = Colors.deepPurple;
    for (int i = 1; i <= 12; i++) {
      Rect rect = Rect.fromCircle(center: hourCoordinates[i], radius: 7);
      canvas.drawArc(rect, 0, 2 * pi, true, hourDotsPaint);
    }

    ///second
    Paint secondPaint = Paint()..color = Colors.red;
    canvas.drawLine(clockProvider.secondsCoordinate[second],
        Offset(size.width / 2, size.height / 2), secondPaint);

    ///minute
    Paint minutePaint = Paint()..color = Colors.blue;
    canvas.drawLine(clockProvider.minutesCoordinate[minute],
        Offset(size.width / 2, size.height / 2), minutePaint);

    ///hour
    Paint hourPaint = Paint()..color = Colors.black;
    canvas.drawLine(analogHourCoordinate,
        Offset(size.width / 2, size.height / 2), hourPaint);

    ///center of clock
    for (double i = 0; i <= 10; i = i + 1) {
      Paint centerClockPaint = Paint()
        ..color = Color.fromRGBO(0, 0, 0, i * i * i);
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
