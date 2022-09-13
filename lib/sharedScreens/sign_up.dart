
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:meetroom/sharedScreens/home_screen.dart';
import 'package:meetroom/sharedScreens/sign_in.dart';
import 'package:meetroom/services/database.dart';
import 'package:the_validator/the_validator.dart';
import '../services/auth.dart';
import '../shared/constants.dart';

class SignUp extends StatefulWidget {
  final bool isStudent, isGoogleAccount;
  const SignUp(
      {Key? key, required this.isStudent, required this.isGoogleAccount})
      : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final nameController = TextEditingController();
  final rollNoController = TextEditingController();
  final cnicController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late bool loading;
  String uid = '';

  fetchUserData() async {
    var currentUser = _auth.getCurrentUser();
    DocumentSnapshot variable = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .get();
    setState(() {
      nameController.text = variable['name'];
      emailController.text = variable['email'];
      uid = variable['uid'];
      loading = false;
    });
  }

  @override
  void initState() {
    if (widget.isGoogleAccount) {
      loading = true;
      fetchUserData();
    } else {
      loading = false;
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    cnicController.dispose();
    rollNoController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: Center(
                          child: Text(
                              widget.isStudent
                                  ? 'Student Sign Up'
                                  : 'Teacher Sign Up',
                              style: kBodyText.copyWith(
                                  color: kWhite,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      //Name
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: TextFormField(
                          controller: nameController,
                          style: kBodyText.copyWith(color: kWhite),
                          cursorColor: kPrimaryColor,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 20),
                            hintText: 'Name',
                            hintStyle: kBodyText.copyWith(color: kGrey),
                            prefixIcon: Icon(
                              Icons.person_outline,
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
                            FieldValidator.minLength(4,
                                message: 'Please enter a valid name'),
                          ]),
                        ),
                      ),

                      //Roll No
                      Visibility(
                        visible: widget.isStudent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          child: TextFormField(
                            controller: rollNoController,
                            style: kBodyText.copyWith(color: kWhite),
                            cursorColor: kPrimaryColor,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              hintText: 'Reg/Roll No.',
                              hintStyle: kBodyText.copyWith(color: kGrey),
                              prefixIcon: Icon(
                                Icons.numbers_outlined,
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
                            validator: FieldValidator.required(),
                          ),
                        ),
                      ),

                      //Cnic
                      Visibility(
                        visible: !widget.isStudent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          child: TextFormField(
                            controller: cnicController,
                            style: kBodyText.copyWith(color: kWhite),
                            cursorColor: kPrimaryColor,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              hintText: 'CNIC',
                              hintStyle: kBodyText.copyWith(color: kGrey),
                              prefixIcon: Icon(
                                Icons.badge_outlined,
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
                              FieldValidator.minLength(13,
                                  message: 'Please enter a valid CNIC'),
                              FieldValidator.maxLength(13,
                                  message: 'Please enter a valid CNIC'),
                            ]),
                          ),
                        ),
                      ),

                      //Email
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: TextFormField(
                          controller: emailController,
                          style: kBodyText.copyWith(color: kWhite),
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

                      //Phone
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: TextFormField(
                          controller: phoneController,
                          style: kBodyText.copyWith(color: kWhite),
                          cursorColor: kPrimaryColor,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 20),
                            hintText: 'Phone',
                            hintStyle: kBodyText.copyWith(color: kGrey),
                            prefixIcon: Icon(
                              Icons.phone_outlined,
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
                            FieldValidator.minLength(10,
                                message: 'Please enter a valid phone'),
                          ]),
                        ),
                      ),

                      //Password
                      Visibility(
                        visible: !widget.isGoogleAccount,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          child: TextFormField(
                              controller: passwordController,
                              style: kBodyText,
                              obscureText: _obscurePassword,
                              cursorColor: kPrimaryColor,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                hintText: 'Password',
                                hintStyle: kBodyText.copyWith(color: kGrey),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: kGrey,
                                  size: 22,
                                ),
                                errorStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 1),
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
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: kGrey,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toggle the state of passwordVisible variable
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'This field is required';
                                }
                                if (val.length < 6) {
                                  return 'Password must be of at least 6 characters';
                                }
                                return null;
                              }),
                        ),
                      ),

                      //Password
                      Visibility(
                        visible: !widget.isGoogleAccount,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          child: TextFormField(
                              controller: confirmPasswordController,
                              style: kBodyText,
                              obscureText: _obscureConfirmPassword,
                              cursorColor: kPrimaryColor,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                hintText: 'Confirm Password',
                                hintStyle: kBodyText.copyWith(color: kGrey),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: kGrey,
                                  size: 22,
                                ),
                                errorStyle: const TextStyle(
                                  fontSize: 16.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 1),
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
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: kGrey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'This field is required';
                                }
                                if (val != passwordController.text) {
                                  return 'Password must be same';
                                }
                                if (val.length < 6) {
                                  return 'Password must be same';
                                }
                                return null;
                              }),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () async {
                              FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              if (widget.isStudent && !widget.isGoogleAccount) {
                                dynamic result = await _auth
                                    .registerStudentWithEmailAndPassword(
                                  emailController.text,
                                  passwordController.text,
                                );

                                if (result == null) {
                                  await DatabaseService(
                                          uid: _auth.getCurrentUser())
                                      .addStudentData(
                                          _auth.getCurrentUser(),
                                          nameController.text,
                                          rollNoController.text,
                                          emailController.text,
                                          phoneController.text);
                                  Get.offAll(() => const HomeScreen());
                                } else {
                                  setState(() {
                                    loading = false;
                                    Get.snackbar(
                                      'Error',
                                      result,
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.red,
                                      colorText: kWhite,
                                      borderRadius: 10,
                                    );
                                  });
                                }
                              } else if (!widget.isStudent &&
                                  !widget.isGoogleAccount) {
                                dynamic result = await _auth
                                    .registerTeacherWithEmailAndPassword(
                                  emailController.text,
                                  passwordController.text,
                                );

                                if (result == null) {
                                  await DatabaseService(
                                          uid: _auth.getCurrentUser())
                                      .addTeacherData(
                                    _auth.getCurrentUser(),
                                    nameController.text,
                                    cnicController.text,
                                    emailController.text,
                                    phoneController.text,
                                  );
                                  Get.offAll(() => const HomeScreen());
                                } else {
                                  setState(() {
                                    loading = false;
                                    Get.snackbar(
                                      'Error',
                                      result,
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.red,
                                      colorText: kWhite,
                                      borderRadius: 10,
                                    );
                                  });
                                }
                              } else if (widget.isStudent &&
                                  widget.isGoogleAccount) {
                                await DatabaseService(uid: uid)
                                    .updateStudentData(
                                  uid,
                                  nameController.text,
                                  rollNoController.text,
                                  emailController.text,
                                  phoneController.text,
                                );
                                Get.offAll(() => const HomeScreen());
                              } else if (!widget.isStudent &&
                                  widget.isGoogleAccount) {
                                await DatabaseService(uid: uid)
                                    .updateTeacherData(
                                  uid,
                                  nameController.text,
                                  cnicController.text,
                                  emailController.text,
                                  phoneController.text,
                                );
                                Get.offAll(() => const HomeScreen());
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
                                      'SIGN UP',
                                      style: kBodyText.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: kWhite),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      Visibility(
                        visible: !widget.isGoogleAccount,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: GestureDetector(
                            onTap: () => Get.to(() => const SignIn()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: kBodyText,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Sign In",
                                  style:
                                      kBodyText.copyWith(color: kPrimaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
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
