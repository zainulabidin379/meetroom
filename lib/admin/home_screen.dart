import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetroom/admin/user_types.dart';

import '../services/auth.dart';
import '../shared/constants.dart';
import '../sharedScreens/sign_in.dart';

class HomeScreenAdmin extends StatefulWidget {
  const HomeScreenAdmin({Key? key}) : super(key: key);

  @override
  State<HomeScreenAdmin> createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  final AuthService _auth = AuthService();
  //Function to manage exit app button
  Future<bool> _onWillPop() async {
    return (await (Get.defaultDialog(
          title: 'Exit MeetRoom',
          titleStyle: kBodyText.copyWith(fontWeight: FontWeight.bold),
          backgroundColor: kBlack,
          content: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              'Do you want to exit?',
              style: kBodyText,
            ),
          ),
          titlePadding: const EdgeInsets.symmetric(vertical: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No',
                  style: kBodyText.copyWith(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Exit',
                  style: kBodyText.copyWith(
                      color: kRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ))) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: kBlack,
          appBar: AppBar(
            backgroundColor: kBlack,
            elevation: 0,
            title: Text(
              'Admin Panel',
              style: GoogleFonts.merienda(
                  fontSize: 25,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () {
                  Get.defaultDialog(
                    title: 'Logout?',
                    titleStyle: kBodyText.copyWith(fontWeight: FontWeight.bold),
                    backgroundColor: kBlack,
                    content: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Do you want to Logout?',
                        style: kBodyText,
                      ),
                    ),
                    titlePadding: const EdgeInsets.symmetric(vertical: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('No',
                            style: kBodyText.copyWith(
                                fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.to(() => const SignIn());
                          await _auth.signOut();
                          Get.snackbar(
                            'Message',
                            'Signed Out Successfully',
                            duration: const Duration(seconds: 3),
                            backgroundColor: kPrimaryColor,
                            colorText: kWhite,
                            borderRadius: 10,
                          );
                        },
                        child: Text('Logout',
                            style: kBodyText.copyWith(
                                color: kRed, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.logout,
                    color: kWhite,
                    size: 28,
                  ),
                ),
              )
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    Get.to(() => const UserTypes(
                          isApproved: true,
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    width: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: kGrey, width: 0.5)),
                    child: Column(
                      children: [
                        SizedBox(
                            height: size.width * 0.35,
                            width: size.width * 0.35,
                            child: Icon(
                              Icons.verified_outlined,
                              color: kPrimaryColor,
                              size: 100,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Approved Users',
                          textAlign: TextAlign.center,
                          style: kBodyText.copyWith(fontSize: 25),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    Get.to(() => const UserTypes(
                          isApproved: false,
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    width: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: kGrey, width: 0.5)),
                    child: Column(
                      children: [
                        SizedBox(
                            height: size.width * 0.35,
                            width: size.width * 0.35,
                            child: Icon(
                              Icons.dangerous_outlined,
                              color: kPrimaryColor,
                              size: 100,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Disapproved Users',
                          textAlign: TextAlign.center,
                          style: kBodyText.copyWith(fontSize: 25),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
