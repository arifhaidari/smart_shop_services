class UserModel {
  int id;
  String name;
  String phone;
  String email;
  String business;
  String address;
  String password;
  String logo;
  bool remember_me;
  String access_code;
  String start_contract_at;
  String end_contract_at;

  ///a user can change anything but it's access code and it's phone number
  ///when user want to change password they should have internet connection that we should be able to
  ///verify the access code and the user contract
  ///in sign up there is also the internet connection is required that we send the data to server and verify user credibility
  ///this feature will help us to track down our valid and active users.
  ///in case of install in new device they should sign in again but with entering the access as well and haivng internet connection
  ///and we keep track of this by creating new database .... we check if they make a new database then they should report us first
  ///that he is a valid user and has still contract going on...
  ///find away to track the phone serial or mac address to make sure that they are using one access code to a single phone not to
  ///more than one...

  UserModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.business,
    this.address,
    this.password,
    this.logo = "no_logo",
    this.remember_me,
    this.access_code,
    this.start_contract_at,
    this.end_contract_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'business': business,
      'address': address,
      'password': password,
      'logo': logo,
      'remember_me': remember_me,
      'access_code': access_code,
      'start_contract_at': start_contract_at,
      'end_contract_at': end_contract_at,
    };
  }

  UserModel.fromDb(Map map)
      : id = map["id"],
        name = map["name"],
        phone = map["phone"],
        email = map["email"],
        business = map["business"],
        address = map["address"],
        password = map["password"],
        logo = map["logo"],
        remember_me = map["remember_me"] == 1 ? true : false,
        access_code = map["access_code"],
        start_contract_at = map["start_contract_at"],
        end_contract_at = map["end_contract_at"];

  factory UserModel.fromJson(Map<String, dynamic> item) {
    return UserModel(
      // id: item['id'],
      name: item['full_name'],
      phone: item['phone'],
      email: item['email'],
      business: item['business'],
      address: item['address'],
      password: item['password'],
      remember_me: item['remember_me'] == null ? true : true,
      access_code: item['access_code'],
      start_contract_at: item['start_contract_at'].toString(),
      end_contract_at: item['end_contract_at'].toString(),
    );
  }
}
