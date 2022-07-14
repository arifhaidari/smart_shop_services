class AppLanguage {
  int id;
  String language_code;
  String country_code;
  bool active;

  AppLanguage({
    this.id,
    this.language_code,
    this.country_code,
    this.active,
  });

  Map<String, dynamic> toMap() {
    return {'language_code': language_code, 'country_code': country_code, 'active': active};
  }

  AppLanguage.fromDb(Map map)
      : id = map["id"],
        language_code = map["language_code"],
        country_code = map['country_code'],
        active = map['active'] == 1 ? true : false;
}
