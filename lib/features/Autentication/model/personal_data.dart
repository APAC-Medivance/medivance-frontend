class PersonalDataModel {
  final String? id;
  final String name;
  final String address;
  final String phone;
  final int Age;
  final int Weight;
  final int Height;

  const PersonalDataModel({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.Age,
    required this.Weight,
    required this.Height,
  });

  toJson(){
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'Age': Age,
      'Weight': Weight,
      'Height': Height,
    };
  }
}