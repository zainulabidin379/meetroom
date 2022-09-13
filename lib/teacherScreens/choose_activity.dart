import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetroom/teacherScreens/add_announcement.dart';
import 'package:meetroom/teacherScreens/add_assignment.dart';
import 'package:meetroom/teacherScreens/add_attendance.dart';
import 'package:meetroom/teacherScreens/add_quiz.dart';
import '../shared/constants.dart';

class ChooseActivityType extends StatefulWidget {
  final String subjectCode;
  final String teacherName;
  final String subjectName;
  const ChooseActivityType(
      {Key? key,
      required this.subjectCode,
      required this.teacherName,
      required this.subjectName})
      : super(key: key);

  @override
  State<ChooseActivityType> createState() => _ChooseActivityTypeState();
}

class _ChooseActivityTypeState extends State<ChooseActivityType> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: kBlack,
        elevation: 0,
        //back Button
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: GestureDetector(
        onTap: (() => FocusScope.of(context).unfocus()),
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 20),
                      child: Center(
                        child: Text('Choose Activity Type',
                            style: kBodyText.copyWith(
                                color: kWhite,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: size.width * 0.35,
                          height: size.width * 0.45,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              Get.to(() => AddAssignment(
                                    subjectCode: widget.subjectCode,
                                    teacherName: widget.teacherName,
                                    subjectName: widget.subjectName,
                                  ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: kGrey, width: 0.5)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                      height: size.width * 0.25,
                                      width: size.width * 0.25,
                                      child: Image.asset(
                                          'assets/icons/assignment.png',
                                          color: kPrimaryColor)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  AutoSizeText(
                                    'Assignment',
                                    style: kBodyText.copyWith(fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.35,
                          height: size.width * 0.45,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              Get.to(() => AddQuiz(
                                    subjectCode: widget.subjectCode,
                                    teacherName: widget.teacherName,
                                    subjectName: widget.subjectName,
                                  ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: kGrey, width: 0.5)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                      height: size.width * 0.25,
                                      width: size.width * 0.25,
                                      child: Image.asset(
                                          'assets/icons/quiz.png',
                                          color: kPrimaryColor)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  AutoSizeText(
                                    'Quiz',
                                    style: kBodyText.copyWith(fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: size.width * 0.35,
                          height: size.width * 0.45,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              Get.to(() => AddAttendance(
                                    subjectCode: widget.subjectCode,
                                    teacherName: widget.teacherName,
                                    subjectName: widget.subjectName,
                                  ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: kGrey, width: 0.5)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                      height: size.width * 0.25,
                                      width: size.width * 0.25,
                                      child: Image.asset(
                                          'assets/icons/attendance.png',
                                          color: kPrimaryColor)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  AutoSizeText(
                                    'Attendance',
                                    style: kBodyText.copyWith(fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.35,
                          height: size.width * 0.45,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              Get.to(() => AddAnnouncement(
                                    subjectCode: widget.subjectCode,
                                    teacherName: widget.teacherName,
                                    subjectName: widget.subjectName,
                                  ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: kGrey, width: 0.5)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                      height: size.width * 0.25,
                                      width: size.width * 0.25,
                                      child: Image.asset(
                                          'assets/icons/announcement.png',
                                          color: kPrimaryColor)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  AutoSizeText(
                                    'Announcement',
                                    maxLines: 1,
                                    style: kBodyText.copyWith(fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
