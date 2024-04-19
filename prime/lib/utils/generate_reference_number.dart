import 'dart:math';

String generateReferenceNumber(String objectType) {
  String randomString(int length) {
    var rand = Random();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          rand.nextInt(chars.length),
        ),
      ),
    );
  }

  String identifier = randomString(8);

  String currentDate = DateTime.now().toString().substring(8, 10) +
      DateTime.now().toString().substring(5, 7) +
      DateTime.now().toString().substring(2, 4);

  return '${objectType}_$currentDate$identifier';
}
