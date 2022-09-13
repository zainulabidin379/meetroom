import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meetroom/shared/constants.dart';
import 'package:open_file/open_file.dart';

class DownloadingDialog extends StatefulWidget {
  final String url;
  final String fileName;
  final String path;
  const DownloadingDialog(
      {Key? key, required this.url, required this.fileName, required this.path})
      : super(key: key);

  @override
  State<DownloadingDialog> createState() => _DownloadingDialogState();
}

class _DownloadingDialogState extends State<DownloadingDialog> {
  Dio dio = Dio();
  double progress = 0.0;

  void startDownloading() async {
    await dio.download(
      widget.url,
      widget.path,
      onReceiveProgress: (receivedBytes, totalBytes) {
        setState(() {
          progress = receivedBytes / totalBytes;
        });
      },
      deleteOnError: true,
    ).then((_) {
      Navigator.pop(context);
      OpenFile.open(widget.path);
    });
  }

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  @override
  Widget build(BuildContext context) {
    String downloadingProgress = (progress * 100).toInt().toString();

    return AlertDialog(
      backgroundColor: kBlack,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Downloading: $downloadingProgress%",
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
