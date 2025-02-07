import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redpulse/features/screens/admin/home.dart';
import 'package:redpulse/features/screens/admin/inventory.dart';
import 'package:redpulse/features/screens/admin/profile.dart';
import 'package:redpulse/features/screens/admin/reservation.dart';
import 'package:redpulse/utilities/constants/styles.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ABottomBar extends StatefulWidget {
  final bool isAdminLinkedToBloodBank;

  const ABottomBar({super.key, required this.isAdminLinkedToBloodBank});

  Future<String?> get bloodBankId async {
    try {
      // Fetch the current authenticated user.
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Admin is not logged in.");
      }

      // Retrieve the admin document from Firestore.
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!adminSnapshot.exists) {
        throw Exception("Admin document not found.");
      }

      // Check and retrieve the bloodBankId.
      String? bloodBankId = adminSnapshot['bloodBankId'];
      if (bloodBankId == null || bloodBankId.isEmpty) {
        throw Exception("Admin is not linked to a blood bank.");
      }
      return bloodBankId;
    } catch (error) {
      print("Error fetching bloodBankId: $error");
      return null;
    }
  }

  @override
  State<ABottomBar> createState() => _ABottomBarState();
}

class _ABottomBarState extends State<ABottomBar> {
  // The currently selected tab index.
  int _selectedIndex = 0;

  // Global key for the CurvedNavigationBar widget.
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Navigation history to keep track of previously selected tab indices.
  final List<int> _navigationHistory = [0];

  /// Dynamically creates the widget options based on the provided bloodBankId.
  List<Widget> _getWidgetOptions(String? bloodBankId) {
    return [
      AdminHome(
        isAdminLinkedToBloodBank: widget.isAdminLinkedToBloodBank,
        bloodBankId: '', // Pass an empty string or a default value if needed.
      ),
      AdminReservationScreen(bloodBankId: bloodBankId ?? "null"),
      Inventory(bloodBankId: bloodBankId ?? "null"),
      const ProfileScreen(),
    ];
  }

  /// Updates the selected tab and records the change in the navigation history.
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
        _navigationHistory.add(index);
      });
    }
  }

  /// Intercepts the back button press.
  ///
  /// If there is a previous tab in the history, this method updates the UI
  /// to show that tab and returns false to indicate that the pop has been handled.
  /// If no history remains, it returns true to allow the default behavior.
  Future<bool> _onWillPop() async {
    if (_navigationHistory.length > 1) {
      setState(() {
        _navigationHistory.removeLast();
        _selectedIndex = _navigationHistory.last;
      });
      return false; // Handled internally.
    }
    return true; // No more history; allow default back button behavior.
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: widget.bloodBankId, // Asynchronously fetch the bloodBankId.
      builder: (context, snapshot) {
        // Use the fetched bloodBankId or a default value.
        String? bloodBankId = snapshot.hasData ? snapshot.data : "null";
        // Create the list of widget options based on the bloodBankId.
        List<Widget> _widgetOptions = _getWidgetOptions(bloodBankId);

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: Colors.red,
            body: Center(
              child: _widgetOptions[_selectedIndex],
            ),
            bottomNavigationBar: CurvedNavigationBar(
              key: _bottomNavigationKey,
              index: _selectedIndex,
              height: 65.0,
              items: const <Widget>[
                Icon(Icons.home_outlined, size: 30, color: Colors.white),
                Icon(Icons.ballot_outlined, size: 30, color: Colors.white),
                Icon(Icons.bloodtype_outlined, size: 30, color: Colors.white),
                Icon(Icons.person_outline_rounded, size: 30, color: Colors.white),
              ],
              // The color of the navigation bar itself.
              color: Styles.primaryColor,
              // The background color of the floating button (the selected tab).
              buttonBackgroundColor: const Color(0xFFB8001F),
              // The color that fills the area behind the navigation bar.
              backgroundColor: Colors.white,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 600),
              onTap: _onItemTapped,
              letIndexChange: (index) => true,
            ),
          ),
        );
      },
    );
  }
}
