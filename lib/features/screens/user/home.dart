import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redpulse/features/screens/user/sub/userCardsHome.dart';
import 'package:redpulse/services/auth.dart';
import 'package:redpulse/utilities/constants/styles.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  UserHomeState createState() => UserHomeState();
}

class UserHomeState extends State<UserHome> {
  late Future<String> _userFullNameFuture;

  @override
  void initState() {
    super.initState();
    _userFullNameFuture = AuthMethod().getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(

        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Styles.primaryColor,
          elevation: 0,
          // Adjust the border of the AppBar using the shape property.
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text("RED PULSE", style: Styles.headerStyle1),
                  Text(
                    "Saving lives, One drop at a time.",
                    style: Styles.headerStyle3.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<String>(
        future: _userFullNameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error fetching user name.'));
          } else {
            final fullName = snapshot.data!;
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                  child: Text(
                    "Welcome, $fullName!",
                    style: GoogleFonts.robotoMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Styles.primaryColor,
                    ),
                  ),
                ),
                const userCardsHome(),
              ],
            );
          }
        },
      ),
    );
  }
}
