import 'package:flutter/material.dart';
import 'package:redpulse/features/screens/user/reservation.dart';
import 'package:redpulse/features/screens/user/home.dart';
import 'package:redpulse/features/screens/user/profile.dart';
import 'package:redpulse/features/screens/user/search.dart';
import 'package:redpulse/utilities/constants/styles.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class UBottomBar extends StatefulWidget {
  const UBottomBar({super.key});

  @override
  State<UBottomBar> createState() => _UBottomBarState();
}

class _UBottomBarState extends State<UBottomBar> {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [0];
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  static final List<Widget> _widgetOptions = <Widget>[
    const UserHome(),
    const SearchScreen(),
    const ReservationScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        _navigationHistory.add(index);
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.length > 1) {
      setState(() {
        _navigationHistory.removeLast();
        _selectedIndex = _navigationHistory.last;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _widgetOptions[_selectedIndex],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _selectedIndex,
          height: 65.0,
          items: const <Widget>[
            Icon(Icons.home_outlined, size: 30, color: Colors.white),
            Icon(Icons.search_rounded, size: 30, color: Colors.white),
            Icon(Icons.monitor_heart_outlined, size: 30, color: Colors.white),
            Icon(Icons.person_outline_rounded, size: 30, color: Colors.white),
          ],
          color: Styles.primaryColor,
          buttonBackgroundColor: const Color(0xFFB8001F),
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: _onItemTapped,
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}
