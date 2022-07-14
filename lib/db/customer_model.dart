class CustomerModel {
  int id;
  String name;
  String address;
  String phone;
  String email;

  CustomerModel({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }

  CustomerModel.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        address = map["address"],
        phone = map["phone"],
        email = map["email"];

  factory CustomerModel.fromJson(Map<String, dynamic> item) {
    return CustomerModel(
      id: item['customer_pk'],
      name: item['name'],
      address: item['address'],
      phone: item['phone'],
      email: item['email'],
    );
  }
}
