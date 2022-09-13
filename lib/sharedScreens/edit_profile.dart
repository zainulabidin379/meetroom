import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetroom/sharedScreens/home_screen.dart';
import 'package:meetroom/services/database.dart';
import 'package:the_validator/the_validator.dart';
import '../services/auth.dart';
import '../shared/constants.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  final nameController = TextEditingController();
  final rollNoController = TextEditingController();
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();
  bool loading = false;
  String uid = '';

  Future getUser() async {
    var currentUser = _auth.getCurrentUser();
    var firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection('users').doc(currentUser).get();
    if (snapshot['isStudent'] == true) {
      setState(() {
        nameController.text = snapshot['name'];
        rollNoController.text = snapshot['rollNo'];
        phoneController.text = snapshot['phone'];
      });
    } else {
      setState(() {
        nameController.text = snapshot['name'];
        cnicController.text = snapshot['cnic'];
        phoneController.text = snapshot['phone'];
      });
    }
  }

  @override
  void initState() {
    uid = _auth.getCurrentUser();
    getUser();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    cnicController.dispose();
    rollNoController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  late File _dpImage;
  final picker = ImagePicker();
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _dpImage = File(pickedFile!.path);
    });
    Get.snackbar(
      'Message',
      'Uploading Profile Image',
      duration: const Duration(seconds: 3),
      backgroundColor: kPrimaryColor,
      colorText: kWhite,
      borderRadius: 10,
    );
    uploadImageToFirebase();
  }

  Future uploadImageToFirebase() async {
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profilePictures/$uid');
    UploadTask uploadTask = firebaseStorageRef.putFile(_dpImage);
    try {
      uploadTask.whenComplete(() async {
        String url = await firebaseStorageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .update({"dpUrl": url});
      });
    } on FirebaseException catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        duration: const Duration(seconds: 3),
        backgroundColor: kRed,
        colorText: kWhite,
        borderRadius: 10,
      );
    }
    //return url;
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
          child: StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_auth.getCurrentUser())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SpinKitCircle(
                      color: kPrimaryColor,
                      size: 13,
                    ),
                  );
                } else {
                  return Column(
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
                                  child: Text('Edit Profile',
                                      style: kBodyText.copyWith(
                                          color: kWhite,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    clipBehavior: Clip.none,
                                    children: [
                                      (snapshot.data['dpUrl'] == null)
                                          ? CircleAvatar(
                                              backgroundImage: const AssetImage(
                                                  'assets/icons/user.png'),
                                              backgroundColor: kPrimaryColor,
                                            )
                                          : CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                snapshot.data['dpUrl'],
                                              ),
                                              backgroundColor: kPrimaryColor,
                                            ),
                                      Positioned(
                                        right: -8,
                                        bottom: 0,
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              pickImage();
                                            },
                                            child: Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.edit,
                                                  color: kWhite,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 20),
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
                                visible: snapshot.data['isStudent'],
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
                                          const EdgeInsets.symmetric(
                                              vertical: 20),
                                      hintText: 'Reg/Roll No.',
                                      hintStyle:
                                          kBodyText.copyWith(color: kGrey),
                                      prefixIcon: Icon(
                                        Icons.numbers_outlined,
                                        color: kGrey,
                                        size: 22,
                                      ),
                                      errorStyle: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        borderSide: BorderSide(
                                            color: kPrimaryColor, width: 1),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        borderSide: BorderSide(
                                          color: kGrey,
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
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
                                visible: !snapshot.data['isStudent'],
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
                                          const EdgeInsets.symmetric(
                                              vertical: 20),
                                      hintText: 'CNIC',
                                      hintStyle:
                                          kBodyText.copyWith(color: kGrey),
                                      prefixIcon: Icon(
                                        Icons.badge_outlined,
                                        color: kGrey,
                                        size: 22,
                                      ),
                                      errorStyle: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        borderSide: BorderSide(
                                            color: kPrimaryColor, width: 1),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        borderSide: BorderSide(
                                          color: kGrey,
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
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

                              //Phone
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20),
                                child: TextFormField(
                                  controller: phoneController,
                                  style: kBodyText.copyWith(color: kWhite),
                                  cursorColor: kPrimaryColor,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 20),
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
                                  ),
                                  validator: FieldValidator.multiple([
                                    FieldValidator.required(),
                                    FieldValidator.minLength(10,
                                        message: 'Please enter a valid phone'),
                                  ]),
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
                                      if (snapshot.data['isStudent']) {
                                        await DatabaseService(uid: uid)
                                            .editStudentData(
                                          uid,
                                          nameController.text,
                                          rollNoController.text,
                                          phoneController.text,
                                        );
                                        Get.offAll(() => const HomeScreen());
                                      } else {
                                        await DatabaseService(uid: uid)
                                            .editStudentData(
                                          uid,
                                          nameController.text,
                                          cnicController.text,
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
                                              'Update Profile',
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}
