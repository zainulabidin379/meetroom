import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference meetroomCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addUserData(
      String uid, String? name, String? email, String? dpUrl) async {
    return await meetroomCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'dpUrl': dpUrl,
      'isApproved': false,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> addStudentData(String uid, String? name, String? rollNo,
      String? email, String? phone) async {
    return await meetroomCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'rollNo': rollNo,
      'email': email,
      'phone': phone,
      'isStudent': true,
      'dpUrl': null,
      'isApproved': false,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> updateStudentData(String uid, String? name, String? rollNo,
      String? email, String? phone) async {
    return await meetroomCollection.doc(uid).update({
      'name': name,
      'rollNo': rollNo,
      'email': email,
      'phone': phone,
      'isStudent': true,
      'dpUrl': null,
    });
  }
  Future<void> editStudentData(String uid, String? name, String? rollNo,
      String? phone) async {
    return await meetroomCollection.doc(uid).update({
      'name': name,
      'rollNo': rollNo,
      'phone': phone,
    });
  }

  Future<void> addTeacherData(String uid, String? name, String cnic,
      String? email, String phone) async {
    return await meetroomCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'cnic': cnic,
      'email': email,
      'phone': phone,
      'isStudent': false,
      'dpUrl': null,
      'isApproved': false,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> updateTeacherData(String uid, String? name, String cnic,
      String? email, String phone) async {
    return await meetroomCollection.doc(uid).update({
      'name': name,
      'cnic': cnic,
      'email': email,
      'phone': phone,
    });
  }

  Future<void> editTeacherData(String uid, String? name, String cnic,
      String phone) async {
    return await meetroomCollection.doc(uid).update({
      'name': name,
      'cnic': cnic,
      'phone': phone,
    });
  }
}
