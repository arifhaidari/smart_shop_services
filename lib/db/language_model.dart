class Language {
  int id;
  String name;
  String flag;
  String languageCode;

  Language({
    this.id,
    this.name,
    this.flag,
    this.languageCode,
  });

  static List<Language> languageList() {
    return <Language>[
      Language(id: 1, name: "English", flag: "🇺🇸", languageCode: "en"),
      Language(id: 2, name: "دری", flag: "🇦🇫", languageCode: "fa"),
      Language(id: 3, name: "‍‍‍پشتو", flag: "🇦🇫", languageCode: "ps"),
    ];
  }

// toMap() function is same to toJson() function
  Map<String, dynamic> toMap() {
    return {'name': name, 'flag': flag};
  }

  Language.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        flag = map["flag"],
        languageCode = map["language_code"];
}
