import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetroom/guest/create_meeting_guest.dart';
import 'package:meetroom/guest/join_meeting_guest.dart';
import 'package:meetroom/shared/constants.dart';

import '../services/auth.dart';
import '../sharedScreens/sign_in.dart';

class HomeScreenGuest extends StatefulWidget {
  const HomeScreenGuest({Key? key}) : super(key: key);

  @override
  State<HomeScreenGuest> createState() => _HomeScreenGuestState();
}

class _HomeScreenGuestState extends State<HomeScreenGuest> {
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
              'Guest User',
              style: kBodyText.copyWith(
                  fontSize: 27, fontWeight: FontWeight.bold, color: kWhite),
            ),
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
            children: [
              Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: SizedBox(
                        width: size.width * 0.4,
                        child: Image.asset('assets/images/logo.png'))),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'Hi There!',
                    style: GoogleFonts.merienda(
                        fontSize: 30,
                        color: kWhite,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Get.to(() => const JoinMeetingGuest());
                    },
                    child: Container(
                      height: 60,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kPrimaryColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            color: kWhite,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Join Meeting',
                            style: kBodyText.copyWith(
                                fontWeight: FontWeight.bold, color: kWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Get.to(() => const CreateMeetingGuest());
                    },
                    child: Container(
                      height: 60,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kPrimaryColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_box,
                            color: kWhite,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Create Meeting',
                            style: kBodyText.copyWith(
                                fontWeight: FontWeight.bold, color: kWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
