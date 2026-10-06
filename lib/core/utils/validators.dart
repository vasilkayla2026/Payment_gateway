/// Form field validators. Each returns an error message, or `null` when the
/// value is valid. Values are trimmed before checking.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phone = RegExp(r'^\d{10}$');

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name';
    if (name.length < 2) return 'Name is too short';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    if (!_email.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  /// A 10-digit mobile number, digits only.
  static String? phone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Enter your mobile number';
    if (!_phone.hasMatch(phone)) return 'Enter a valid 10-digit mobile number';
    return null;
  }
}
