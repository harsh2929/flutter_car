// lib/utils/validators.dart

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  }
  final regex = RegExp(r'^\S+@\S+\.\S+$');
  if (!regex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
