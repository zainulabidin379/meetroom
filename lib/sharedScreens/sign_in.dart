import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:meetroom/admin/home_screen.dart';
import 'package:meetroom/guest/home_screen_guest.dart';
import 'package:meetroom/sharedScreens/choose_user_type.dart';
import 'package:meetroom/sharedScreens/forgot_password.dart';
import 'package:meetroom/sharedScreens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_validator/the_validator.dart';
import '../services/auth.dart';
import '../shared/constants.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool loading = false;
  bool rememberMe = true;

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

  //handle remember me function
  void handleRememberMe() {
    SharedPreferences.getInstance().then(
      (prefs) {
        prefs.setBool("rememberMe", rememberMe);
        prefs.setString('email', emailController.text);
        prefs.setString('password', passwordController.text);
      },
    );
  }

  //load email and password
  void loadUserEmailPassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      rememberMe = prefs.getBool("rememberMe") ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString("email") ?? "";
        passwordController.text = prefs.getString("password") ?? "";
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  void initState() {
    loadUserEmailPassword();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: kBlack,
        body: GestureDetector(
          onTap: (() => FocusScope.of(context).unfocus()),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.05,
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 30),
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 30.0, horizontal: 20),
                          child: Center(
                            child: Text('Sign In',
                                style: kBodyText.copyWith(
                                    color: kWhite,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold)),
                          ),
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

                        //Password
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          child: TextFormField(
                              controller: passwordController,
                              style: kBodyText,
                              obscureText: _obscurePassword,
                              cursorColor: kPrimaryColor,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                hintText: 'Your Password',
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
                                  return 'Password is required';
                                }
                                if (val.length < 6) {
                                  return 'Password must be of at least 6 characters';
                                }
                                return null;
                              }),
                        ),
                        //Button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    rememberMe = !rememberMe;
                                  });
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 15,
                                      width: 35,
                                      child: Transform.scale(
                                        scale: 0.6,
                                        child: CupertinoSwitch(
                                          value: rememberMe,
                                          activeColor: kPrimaryColor,
                                          onChanged: (bool value) {
                                            setState(() {
                                              rememberMe = !rememberMe;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        'Remember Me',
                                        style: kBodyText.copyWith(
                                            fontSize: 13, color: kWhite),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Get.to(() => const ForgotPassword()),
                                child: Text(
                                  'Forgot Password?',
                                  style: kBodyText.copyWith(
                                      fontSize: 13, color: kWhite),
                                ),
                              ),
                            ],
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
                                setState(() {
                                  loading = true;
                                });

                                dynamic result =
                                    await _auth.signInWithEmailAndPassword(
                                        emailController.text,
                                        passwordController.text);

                                if (result != null) {
                                  setState(() {
                                    loading = false;
                                  });
                                  Get.snackbar(
                                    'Error',
                                    result,
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: kRed,
                                    colorText: kWhite,
                                    borderRadius: 10,
                                  );
                                } else {
                                  handleRememberMe();
                                  if (_auth.getCurrentUser() ==
                                      '2fds3RJi5DNymHQjftUGYQTSTS13') {
                                    Get.offAll(() => const HomeScreenAdmin());
                                  } else {
                                    Get.offAll(() => const HomeScreen());
                                  }
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
                                        'SIGN IN',
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
                        Center(
                          child: Text(
                            'OR',
                            style: kBodyText.copyWith(
                                fontWeight: FontWeight.bold, color: kGrey),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  loading = true;
                                });

                                dynamic result = await _auth.signInAnon();

                                if (result == 'guest') {
                                  Get.offAll(() => const HomeScreenGuest());
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20),
                                height: 60,
                                width: size.width * 0.7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: kPrimaryColor,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        height: 30,
                                        child: Image.asset(
                                            'assets/icons/guest.png')),
                                    Text(
                                      'Login as a Guest',
                                      style: kBodyText.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  loading = true;
                                });

                                dynamic result = await _auth.signInWithGoogle();

                                if (result == null) {
                                  Get.offAll(() => const HomeScreen());
                                } else if (result == 'new') {
                                  Get.snackbar(
                                    'Message',
                                    'Please Sign Up to continue',
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: kPrimaryColor,
                                    colorText: kWhite,
                                    borderRadius: 10,
                                  );
                                  Get.offAll(() => const ChooseUserType(
                                        isGoogleAccount: true,
                                      ));
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  Get.snackbar(
                                    'Error',
                                    result,
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: kRed,
                                    colorText: kWhite,
                                    borderRadius: 10,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20),
                                height: 60,
                                width: size.width * 0.7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: kWhite,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        height: 30,
                                        child: Image.asset(
                                            'assets/icons/google.png')),
                                    Text(
                                      'Login with Google',
                                      style: kBodyText.copyWith(
                                          color: kBlack, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: GestureDetector(
                            onTap: () => Get.to(() => const ChooseUserType(
                                  isGoogleAccount: false,
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: kBodyText,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Sign up",
                                  style:
                                      kBodyText.copyWith(color: kPrimaryColor),
                                ),
                              ],
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
      ),
    );
  }
}
