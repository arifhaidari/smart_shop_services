class VariantOption {
  int id;
  String option_name;
  int variant_id;

  VariantOption({this.id, this.option_name, this.variant_id});

  Map<String, dynamic> toMap() {
    return {
      'option_name': option_name,
      'variant_id': variant_id,
    };
  }

  Map<String, dynamic> importToMap() {
    return {
      'id': id,
      'option_name': option_name,
      'variant_id': variant_id,
    };
  }

  VariantOption.fromDb(Map map)
      : id = map["id"],
        option_name = map["option_name"],
        variant_id = map["variant_id"];

  factory VariantOption.fromJson(Map<String, dynamic> item) {
    return VariantOption(
      id: item['variant_option_pk'],
      option_name: item['option_name'],
      variant_id: item['variant_id'],
    );
  }
}
