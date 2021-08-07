bool isValidName(String text) {
  return RegExp(r"^[a-zA-ZñÑ]+$").hasMatch(text);
}
