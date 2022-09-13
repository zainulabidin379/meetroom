import 'package:flutter/material.dart';
import '../shared/constants.dart';
import '../widgets/meeting_option.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

class JoinMeetingGuest extends StatefulWidget {
  const JoinMeetingGuest({
    Key? key,
  }) : super(key: key);

  @override
  State<JoinMeetingGuest> createState() => _JoinMeetingGuestState();
}

class _JoinMeetingGuestState extends State<JoinMeetingGuest> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  bool isAudioMuted = true;
  bool isVideoMuted = true;
  createNewMeeting() async {
    var options = JitsiMeetingOptions(
        roomNameOrUrl: codeController.text,
        userDisplayName: nameController.text,
        isAudioMuted: isAudioMuted,
        isVideoMuted: isVideoMuted);
    await JitsiMeetWrapper.joinMeeting(
      options: options,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
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
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
              child: Center(
                child: Text('Create Meeting',
                    style: kBodyText.copyWith(
                        color: kWhite,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Code
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20),
                    child: TextFormField(
                        controller: codeController,
                        style: kBodyText,
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Meeting Code',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.pin,
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
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Meeting code is required';
                          }
                          if (val.length != 5) {
                            return 'Please enter valid meeting Code';
                          }
                          return null;
                        }),
                  ),
                  //Name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20),
                    child: TextFormField(
                        controller: nameController,
                        style: kBodyText,
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Your Name',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.person,
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
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Name is required';
                          }
                          if (val.length < 3) {
                            return 'Please enter valid Name';
                          }
                          return null;
                        }),
                  ),
                ],
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
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState!.validate()) {
                    createNewMeeting();
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
                    child: Text(
                      'Create Meeting',
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
