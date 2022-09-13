import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:the_validator/the_validator.dart';
import '../services/auth.dart';
import '../shared/constants.dart';

class AddSubjectStudent extends StatefulWidget {
  const AddSubjectStudent({
    Key? key,
  }) : super(key: key);

  @override
  State<AddSubjectStudent> createState() => _AddSubjectStudentState();
}

class _AddSubjectStudentState extends State<AddSubjectStudent> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
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
                        child: Text('Add Subject',
                            style: kBodyText.copyWith(
                                color: kWhite,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    //name
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: TextFormField(
                        controller: codeController,
                        style: kBodyText,
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Enter Subject Code',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.menu_book,
                            color: kGrey,
                            size: 25,
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 16.0,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: kGrey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: kGrey,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: FieldValidator.multiple([
                          FieldValidator.required(
                              message: 'Subject code is required'),
                          FieldValidator.minLength(5,
                              message: 'Please enter a valid code'),
                          FieldValidator.maxLength(5,
                              message: 'Please enter a valid code'),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            var firestore = FirebaseFirestore.instance;
                            await firestore
                                .collection('subjects')
                                .doc(codeController.text)
                                .get()
                                .then((value) async {
                              if (value.exists) {
                                await firestore
                                    .collection('users')
                                    .doc(_auth.getCurrentUser())
                                    .collection('subjects')
                                    .doc(value['subjectCode'])
                                    .set({
                                  'subjectCode': value['subjectCode'],
                                  'name': value['name'],
                                  'teacher': value['teacher'],
                                  'email': value['email'],
                                  'attended': 0,
                                }).then((value) async {
                                  await FirebaseFirestore.instance
                                      .collection('subjects')
                                      .doc(codeController.text)
                                      .get()
                                      .then((value) async {
                                    await FirebaseFirestore.instance
                                        .collection('subjects')
                                        .doc(codeController.text)
                                        .update({
                                      'totalStudents':
                                          value['totalStudents'] + 1,
                                    }).then((_) async {
                                      await firestore
                                          .collection('users')
                                          .doc(_auth.getCurrentUser())
                                          .get()
                                          .then((value) async {
                                        await firestore
                                            .collection('subjects')
                                            .doc(codeController.text)
                                            .collection('students')
                                            .doc(_auth.getCurrentUser())
                                            .set({
                                          'uid': value['uid'],
                                          'name': value['name'],
                                          'phone': value['phone'],
                                          'email': value['email'],
                                          'dpUrl': value['dpUrl'],
                                          'rollNo': value['rollNo'],
                                        }).then((value) {
                                          Navigator.pop(context);
                                          Get.snackbar(
                                            'Message',
                                            'Enrolled in new subject successfully',
                                            duration:
                                                const Duration(seconds: 3),
                                            backgroundColor: kPrimaryColor,
                                            colorText: kWhite,
                                            borderRadius: 10,
                                          );
                                        });
                                      });
                                    });
                                  });
                                });
                              } else {
                                setState(() {
                                  loading = false;
                                });
                                Get.snackbar(
                                  'Message',
                                  'No subject found against this code',
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: kRed,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
                              }
                            });
                          }
                        },
                        child: Container(
                          height: 60,
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: kPrimaryColor,
                          ),
                          child: Center(
                            child: loading
                                ? SpinKitCircle(
                                    color: kWhite,
                                    size: 50.0,
                                  )
                                : Text(
                                    'Add Subject',
                                    style: kBodyText.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: kWhite),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 35,
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
