import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:meetroom/admin/home_screen.dart';
import 'package:meetroom/guest/home_screen_guest.dart';
import 'package:meetroom/sharedScreens/home_screen.dart';
import 'package:meetroom/sharedScreens/sign_in.dart';
import 'package:provider/provider.dart';

import '../shared/constants.dart';
import '../shared/user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TheUser? user = Provider.of<TheUser?>(context);
    if (user == null) {
      return const SignIn();
    } else {
      return Scaffold(
        backgroundColor: kBlack,
        body: StreamBuilder<dynamic>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SpinKitCircle(
                    color: kPrimaryColor,
                    size: 50.0,
                  ),
                );
              } else {
                if (snapshot.data!.exists) {
                  return const HomeScreen();
                } else {
                  if (user.uid == '2fds3RJi5DNymHQjftUGYQTSTS13') {
                    return const HomeScreenAdmin();
                  } else {
                    return const HomeScreenGuest();
                  }
                }
              }
            }),
      );
    }
  }
}
