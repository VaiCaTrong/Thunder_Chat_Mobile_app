/// Get the first letter of a name safely
String getInitial(String? name, {String fallback = '?'}) {
  if (name == null || name.isEmpty) {
    return fallback;
  }
  return name[0].toUpperCase();
}

/// Get display name from fullName or username
String getDisplayName(String? fullName, String username) {
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }
  return username;
}
