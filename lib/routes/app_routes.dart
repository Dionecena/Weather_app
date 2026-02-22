import 'package:flutter/material.dart';
import 'package:examen/models/weather.dart';
import 'package:examen/screens/city_detail_screen.dart';
import 'package:examen/screens/loading_screen.dart';
import 'package:examen/screens/weather_table_screen.dart';

class AppRoutes {
  AppRoutes._();

  static Route<dynamic> slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<dynamic> slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static void toLoading(BuildContext context) {
    Navigator.push(
      context,
      slideFromBottom(const LoadingScreen()),
    );
  }

  static void toWeatherTable(BuildContext context, List<Weather> weatherData) {
    Navigator.pushReplacement(
      context,
      slideFromBottom(WeatherTableScreen(weatherData: weatherData)),
    );
  }

  static void toCityDetail(BuildContext context, Weather weather) {
    Navigator.push(
      context,
      slideFromRight(CityDetailScreen(weather: weather)),
    );
  }

  static void restartToLoading(BuildContext context) {
    Navigator.pushReplacement(
      context,
      slideFromBottom(const LoadingScreen()),
    );
  }
}
