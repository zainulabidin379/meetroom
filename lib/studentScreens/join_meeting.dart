import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import '../services/auth.dart';
import '../shared/constants.dart';
import '../widgets/meeting_option.dart';

class JoinMeeting extends StatefulWidget {
  final String subjectCode;
  final String name;
  final String email;
  const JoinMeeting(
      {Key? key,
      required this.subjectCode,
      required this.name,
      required this.email})
      : super(key: key);

  @override
  State<JoinMeeting> createState() => _JoinMeetingState();
}

class _JoinMeetingState extends State<JoinMeeting> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  bool isAudioMuted = true;
  bool isVideoMuted = true;
  dynamic dpUrl = '';

  Future getUser() async {
    var currentUser = _auth.getCurrentUser();
    var firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection('users').doc(currentUser).get();

    setState(() {
      dpUrl = snapshot['dpUrl'];
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
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
                        child: Text('Join Meeting',
                            style: kBodyText.copyWith(
                                color: kWhite,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    MeetingOption(
                      text: 'Mute Audio',
                      isMute: isAudioMuted,
                      onChange: onAudioMuted,
                    ),
                    MeetingOption(
                      text: 'Turn Off Video',
                      isMute: isVideoMuted,
                      onChange: onVideoMuted,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          Get.defaultDialog(
                            title: '',
                            backgroundColor: Colors.transparent,
                            barrierDismissible: false,
                            content: SpinKitCircle(
                              color: kPrimaryColor,
                              size: 50.0,
                            ),
                          );
                          await FirebaseFirestore.instance
                              .collection('subjects')
                              .doc(widget.subjectCode)
                              .get()
                              .then((value) async {
                            if (value['meeting'] == null) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Get.snackbar(
                                'Message',
                                'Meeting has not started yet!',
                                duration: const Duration(seconds: 3),
                                backgroundColor: kPrimaryColor,
                                colorText: kWhite,
                                borderRadius: 10,
                              );
                            } else {
                              Navigator.pop(context);

                              Map<FeatureFlag, bool> featureFlags = {
                                FeatureFlag.isWelcomePageEnabled: false,
                                FeatureFlag.isInviteEnabled: false,
                              };
                              var options = JitsiMeetingOptions(
                                  featureFlags: featureFlags,
                                  roomNameOrUrl: widget.subjectCode,
                                  userDisplayName: widget.name,
                                  userEmail: widget.email,
                                  userAvatarUrl: dpUrl,
                                  isAudioMuted: isAudioMuted,
                                  isVideoMuted: isVideoMuted);
                              await JitsiMeetWrapper.joinMeeting(
                                  options: options);
                            }
                          });
                        },
                        child: Container(
                          height: 60,
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: kPrimaryColor,
                          ),
                          child: Center(
                            child: Text(
                              'Join Meeting',
                              style: kBodyText.copyWith(
                                  fontWeight: FontWeight.bold, color: kWhite),
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

  onAudioMuted(bool val) {
    setState(() {
      isAudioMuted = val;
    });
  }

  onVideoMuted(bool val) {
    setState(() {
      isVideoMuted = val;
    });
  }
}
