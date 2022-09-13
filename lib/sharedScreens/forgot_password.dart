import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:the_validator/the_validator.dart';
import '../services/auth.dart';
import '../shared/constants.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final emailController = TextEditingController();
  bool loading = false;
  String? errorMessage;
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                      width: size.width * 0.4,
                      child: Image.asset('assets/images/logo.png'))),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, left: 20, right: 20),
                        child: Center(
                          child: Text('Forgot Password',
                              style: kBodyText.copyWith(
                                  color: kWhite,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      //Description Text
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Text(
                          'An email with password reset link will be sent to your registered email.',
                          textAlign: TextAlign.center,
                          style: kBodyText.copyWith(fontSize: 15),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //Email
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
                            hintText: 'Email',
                            hintStyle: kBodyText.copyWith(color: kGrey),
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: kGrey,
                              size: 22,
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
                            FieldValidator.required(),
                            FieldValidator.email(),
                          ]),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              try {
                                await _auth.sendPasswordResetEmail(
                                    emailController.text);
                                Get.back();
                                Get.snackbar(
                                  'Message',
                                  'Email with password reset instructions is sent',
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: kPrimaryColor,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
                              } on FirebaseException catch (error) {
                                switch (error.code) {
                                  case "ERROR_EMAIL_ALREADY_IN_USE":
                                  case "account-exists-with-different-credential":
                                  case "email-already-in-use":
                                    setState(() {
                                      errorMessage =
                                          "Email already used. Go to login page.";
                                    });
                                    break;
                                  case "ERROR_WRONG_PASSWORD":
                                  case "wrong-password":
                                    setState(() {
                                      errorMessage =
                                          "Wrong email/password combination.";
                                    });
                                    break;
                                  case "ERROR_USER_NOT_FOUND":
                                  case "user-not-found":
                                    setState(() {
                                      errorMessage =
                                          "No user found with this email.";
                                    });
                                    break;
                                  case "ERROR_USER_DISABLED":
                                  case "user-disabled":
                                    setState(() {
                                      errorMessage = "User disabled.";
                                    });

                                    break;

                                  case "ERROR_OPERATION_NOT_ALLOWED":
                                  case "operation-not-allowed":
                                    setState(() {
                                      errorMessage =
                                          "Server error, please try again later.";
                                    });
                                    break;
                                  case "ERROR_INVALID_EMAIL":
                                  case "invalid-email":
                                    setState(() {
                                      errorMessage =
                                          "Email address is invalid.";
                                    });
                                    break;
                                  default:
                                    setState(() {
                                      errorMessage =
                                          "Login failed. Please try again.";
                                    });
                                    break;
                                }
                                Get.snackbar(
                                  'Error',
                                  errorMessage!,
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: kRed,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
                              }
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
                                      'SEND REQUEST',
                                      style: kBodyText.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: kWhite),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
