import 'dart:math';

// Define a reusable function
String getRandomString() {
  final random = Random();
  const availableChars =
      'abcdefghijklmnopqrstuvwxyz1234567890';
  final randomString = List.generate(5,
          (index) => availableChars[random.nextInt(availableChars.length)])
      .join();

  return randomString;
}