import 'package:flutter/cupertino.dart';
import 'package:meetroom/shared/constants.dart';

class MeetingOption extends StatelessWidget {
  final String text;
  final bool isMute;
  final Function(bool) onChange;
  const MeetingOption({
    Key? key,
    required this.text,
    required this.isMute,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 60,
      color: kBlack,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: kBodyText,
            ),
          ),
          CupertinoSwitch(
            activeColor: kPrimaryColor,
            trackColor: kGrey.withOpacity(0.5),
            value: isMute,
            onChanged: onChange,
          ),
        ],
      ),
    );
  }
}
