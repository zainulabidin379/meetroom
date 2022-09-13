import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetroom/sharedScreens/sign_up.dart';
import '../shared/constants.dart';

class ChooseUserType extends StatefulWidget {
  final bool isGoogleAccount;
  const ChooseUserType({Key? key, required this.isGoogleAccount})
      : super(key: key);

  @override
  State<ChooseUserType> createState() => _ChooseUserTypeState();
}

class _ChooseUserTypeState extends State<ChooseUserType> {
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
                        child: Text('Sign Up as a',
                            style: kBodyText.copyWith(
                                color: kWhite,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          Get.to(() => SignUp(
                                isStudent: true,
                                isGoogleAccount:
                                    widget.isGoogleAccount ? true : false,
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: kGrey, width: 0.5)),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: size.width * 0.35,
                                  width: size.width * 0.35,
                                  child: Image.asset('assets/icons/student.png',
                                      color: kPrimaryColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Student',
                                style: kBodyText.copyWith(fontSize: 25),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => Get.to(() => SignUp(
                              isStudent: false,
                              isGoogleAccount:
                                  widget.isGoogleAccount ? true : false,
                            )),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: kGrey, width: 0.5)),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: size.width * 0.35,
                                  width: size.width * 0.35,
                                  child: Image.asset('assets/icons/teacher.png',
                                      color: kPrimaryColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Teacher',
                                style: kBodyText.copyWith(fontSize: 25),
                              )
                            ],
                          ),
                        ),
                      ),
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
