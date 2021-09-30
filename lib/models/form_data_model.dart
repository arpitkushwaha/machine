class FormDataModel {
  String firstName;
  String lastName;
  String email;
  String phone;
  String imagePath;

  FormDataModel(
      {this.firstName, this.lastName, this.email, this.phone, this.imagePath});

  FormDataModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    phone = json['phone'];
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['imagePath'] = this.imagePath;
    return data;
  }
}