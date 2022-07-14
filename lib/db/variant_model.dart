class Variant {
  int id;
  String name;

  Variant({
    this.id,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  Variant.fromDb(Map map)
      : id = map["id"],
        name = map["name"];

  factory Variant.fromJson(Map<String, dynamic> item) {
    return Variant(
      id: item['variant_pk'],
      name: item['name'],
    );
  }
}
