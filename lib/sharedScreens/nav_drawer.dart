import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetroom/sharedScreens/edit_profile.dart';
import 'package:meetroom/sharedScreens/sign_in.dart';
import 'package:meetroom/services/auth.dart';
import '../shared/constants.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Drawer(
      backgroundColor: kBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(31), bottomRight: Radius.circular(31)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 280,
            child: DrawerHeader(
              decoration: BoxDecoration(
                  color: kBlack,
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(31))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: (() => Navigator.pop(context)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<dynamic>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.getCurrentUser())
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SpinKitCircle(
                            color: kPrimaryColor,
                            size: 13,
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              if (snapshot.data['isApproved']) {
                                Get.snackbar(
                                  'Congratulations',
                                  'Your profile is verified!',
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: kPrimaryColor,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
                              } else {
                                Get.snackbar(
                                  'Not Approved',
                                  'Please wait until an admin approve your profile',
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: Colors.red,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Stack(
                                        fit: StackFit.expand,
                                        clipBehavior: Clip.none,
                                        children: [
                                          (snapshot.data['dpUrl'] == null)
                                              ? CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor:
                                                      kPrimaryColor,
                                                  backgroundImage:
                                                      const AssetImage(
                                                          'assets/icons/user.png'),
                                                )
                                              : CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor:
                                                      kPrimaryColor,
                                                  backgroundImage: NetworkImage(
                                                      snapshot.data['dpUrl']),
                                                ),
                                          Positioned(
                                            right: -8,
                                            bottom: 0,
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    snapshot.data['isApproved']
                                                        ? Icons.verified
                                                        : Icons.dangerous,
                                                    color: kWhite,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ])),
                                const SizedBox(
                                  height: 15,
                                ),
                                Flexible(
                                  child: Text(
                                    snapshot.data['name'].toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.merienda(
                                        fontSize: size.width * 0.08,
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.mail_outline,
                                      color: kGrey.withOpacity(0.5),
                                      size: 13,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      snapshot.data['email'],
                                      style: kBodyText.copyWith(
                                        fontSize: 13,
                                        color: kGrey.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      })
                ],
              ),
            ),
          ),
          ListTile(
              leading: Icon(
                Icons.person_outline,
                color: kWhite,
                size: 25,
              ),
              title: Text('Edit Profile',
                  style: kBodyText.copyWith(color: kWhite)),
              onTap: () => Get.to(() => const EditProfile())?.then((value) {
                    setState(() {});
                  })),
          ListTile(
            onTap: () async {
              await _auth.signOut();
              Get.to(() => const SignIn());

              Get.snackbar(
                'Message',
                'Signed Out Successfully',
                duration: const Duration(seconds: 3),
                backgroundColor: kPrimaryColor,
                colorText: kWhite,
                borderRadius: 10,
              );
            },
            leading: Icon(
              Icons.logout_outlined,
              color: kWhite,
              size: 25,
            ),
            title: Text('Sign Out', style: kBodyText.copyWith(color: kWhite)),
            // onTap: () => Get.offAll(() => const SignIn()),
          ),
        ],
      ),
    );
  }
}
