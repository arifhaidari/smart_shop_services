class Category {
  int id;
  String name;
  bool include_in_drawer;

  Category({
    this.id,
    this.name,
    this.include_in_drawer,
  });

// toMap() function is same to toJson() function
  Map<String, dynamic> toMap() {
    return {'name': name, 'include_in_drawer': include_in_drawer};
  }

  Map<String, dynamic> importToMap() {
    return {'id': id, 'name': name, 'include_in_drawer': include_in_drawer};
  }

  Category.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        include_in_drawer = map['include_in_drawer'] == 1 ? true : false;

  factory Category.fromJson(Map<String, dynamic> item) {
    return Category(
      id: item['category_pk'],
      name: item['name'],
      include_in_drawer: item['include_in_drawer'],
    );
  }

  // factory Category.fromJsonError(Map<String, dynamic> item) {
  //   return Category(
  //     id: item['category_pk'],
  //     name: item['name'],
  //     include_in_drawer: item['include_in_drawer'],
  //   );
  // }

  /// create from error fromJsonError as well to hadnle
  /// error because of json
}
