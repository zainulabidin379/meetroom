import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../shared/constants.dart';

class ViewAttendance extends StatefulWidget {
  final String subjectCode;
  final String attendanceCode;
  final String date;
  const ViewAttendance(
      {Key? key,
      required this.attendanceCode,
      required this.subjectCode,
      required this.date})
      : super(key: key);

  @override
  State<ViewAttendance> createState() => _ViewAttendanceState();
}

class _ViewAttendanceState extends State<ViewAttendance> {
  Future getAttendanceRecord() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore
        .collection('subjects')
        .doc(widget.subjectCode)
        .collection('data')
        .doc(widget.attendanceCode)
        .collection('attendance')
        .orderBy('timestamp', descending: false)
        .get();

    return qn.docs;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: kBlack,
        elevation: 0,
        //back Button
        leading: Builder(
          builder: (context) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_new)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        color: kPrimaryColor,
        backgroundColor: kBlack,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
              child: Center(
                child: Text('Attendance Record',
                    style: kBodyText.copyWith(
                        color: kWhite,
                        fontSize: 27,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Date: ',
                    style: kBodyText.copyWith(
                        color: kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  Text(
                    widget.date,
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
            FutureBuilder<dynamic>(
                future: getAttendanceRecord(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SpinKitCircle(
                      color: kPrimaryColor,
                      size: 50.0,
                    );
                  } else {
                    return Column(
                      children: [
                        if (snapshot.data.length != 0) ...[
                          for (var i = 0; i < snapshot.data.length; i++) ...{
                            studentCard(
                              size,
                              snapshot.data[i]['name'],
                              snapshot.data[i]['rollNo'],
                            )
                          }
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: SizedBox(
                              width: 250,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: Image.asset(
                                      'assets/icons/noSubjects.png',
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    "No attendance record found!",
                                    textAlign: TextAlign.center,
                                    style: kBodyText.copyWith(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]
                      ],
                    );
                  }
                }),
            const SizedBox(
              height: 20,
            )
          ]),
        ),
      ),
    );
  }

  Widget studentCard(Size size, String name, String rollNo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)]
                .withOpacity(0.3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: kBodyText.copyWith(color: kGrey, fontSize: 15),
                      ),
                      Text(
                        rollNo,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: kBodyText.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
