class Regx {
  // Regex patterns
  static const String fullNamePattern = r'^[A-Za-z]+(?:[ \-][A-Za-z]+)*$';
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[0-9]{7,15}$';
  static const String passwordPattern =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$';

  // Validation methods
  static bool validateFullName(String name) {
    final regex = RegExp(fullNamePattern);
    return regex.hasMatch(name);
  }

  static bool validateEmail(String email) {
    final regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  static bool validatePhoneNumber(String phone) {
    final regex = RegExp(phonePattern);
    return regex.hasMatch(phone) && phone.length == 8;
  }

  static bool validatePassword(String password) {
    final regex = RegExp(passwordPattern);
    return regex.hasMatch(password);
  }

  static bool validateConfirmPassword(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
