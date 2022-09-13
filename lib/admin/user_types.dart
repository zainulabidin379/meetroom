import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/constants.dart';
import 'approved_students.dart';
import 'approved_teachers.dart';
import 'disapproved_students.dart';
import 'disapproved_teachers.dart';

class UserTypes extends StatefulWidget {
  final bool isApproved;
  const UserTypes({Key? key, required this.isApproved}) : super(key: key);

  @override
  State<UserTypes> createState() => _UserTypesState();
}

class _UserTypesState extends State<UserTypes> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: kBlack,
        appBar: AppBar(
          backgroundColor: kBlack,
          elevation: 0,
          title: Text(
            'User Types',
            style: GoogleFonts.merienda(
                fontSize: 22,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  if (widget.isApproved) {
                    Get.to(() => const ApprovedStudents());
                  } else {
                    Get.to(() => const DisapprovedStudents());
                  }
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
                            Icons.school_outlined,
                            color: kPrimaryColor,
                            size: 100,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Students',
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
                  if (widget.isApproved) {
                    Get.to(() => const ApprovedTeachers());
                  } else {
                    Get.to(() => const DisapprovedTeachers());
                  }
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
                            Icons.person_outline,
                            color: kPrimaryColor,
                            size: 100,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Teachers',
                        style: kBodyText.copyWith(fontSize: 25),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
