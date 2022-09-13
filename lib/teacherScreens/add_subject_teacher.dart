import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:meetroom/shared/generate_code.dart';
import 'package:the_validator/the_validator.dart';
import '../services/auth.dart';
import '../shared/constants.dart';

class AddSubjectTeacher extends StatefulWidget {
  final String teacherName;
  final String phone;
  final String email;
  const AddSubjectTeacher(
      {Key? key,
      required this.teacherName,
      required this.email,
      required this.phone})
      : super(key: key);

  @override
  State<AddSubjectTeacher> createState() => _AddSubjectTeacherState();
}

class _AddSubjectTeacherState extends State<AddSubjectTeacher> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  bool loading = false;
  @override
  void initState() {
    emailController.text = widget.email;
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
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
                        child: Text('Add Your Subject',
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
                        controller: nameController,
                        style: kBodyText,
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Subject Name',
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
                              message: 'Subject name is required'),
                          FieldValidator.minLength(2,
                              message: 'Please enter a valid name'),
                        ]),
                      ),
                    ),
                    //name
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: TextFormField(
                        controller: emailController,
                        style: kBodyText,
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Contact Email',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.mail,
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
                              message: 'Your Email is required'),
                          FieldValidator.email()
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          String code = getRandomString();
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            FirebaseFirestore.instance
                                .collection('subjects')
                                .doc(code)
                                .set({
                              'subjectCode': code,
                              'name': nameController.text,
                              'teacher': widget.teacherName,
                              'email': emailController.text,
                              'meeting': null,
                              'totalStudents': 0,
                              'totalClasses': 0,
                              'totalAssignments': 0,
                              'totalQuizzes': 0,
                              'timestamp': DateTime.now(),
                            }).then((value) {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_auth.getCurrentUser())
                                  .collection('subjects')
                                  .doc(code)
                                  .set({
                                'subjectCode': code,
                                'name': nameController.text,
                                'teacher': widget.teacherName,
                                'email': emailController.text,
                                'totalClasses': 0,
                              }).then((value) {
                                Navigator.pop(context);
                                Get.snackbar(
                                  'Message',
                                  'New Subject Added Successfully',
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: kRed,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
                              });
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
