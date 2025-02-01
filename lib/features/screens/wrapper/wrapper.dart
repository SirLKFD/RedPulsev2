import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/abottombar.dart';
import '../../../widgets/ubottombar.dart';
import '../admin/home.dart';
import '../admin/start.dart';
import '../login.dart';
import '../user/home.dart';
import '../user/start.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context);

    if (firebaseUser == null) {
      return const LoginScreen();
    } else {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const LoginScreen();
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final role = userData['role'] as String?;
          final bloodBankId = userData['bloodBankId'] as String?;

          if (role == 'Admin') {
            return ABottomBar(
              isAdminLinkedToBloodBank: bloodBankId?.isNotEmpty ?? false,
            );
          } else {
            return const UBottomBar();
          }
        },
      );
    }
  }
}