class Country {
  final String name, code, dialCode, flag;

  Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  factory Country.fromJson(Map<String, String> json) {
    return Country(
      name: json['name']!,
      code: json['isoCode']!,
      dialCode: json['dialCode']!,
      flag: json['flag']!,
    );
  }
}
