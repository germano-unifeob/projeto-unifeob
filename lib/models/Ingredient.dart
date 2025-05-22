class Ingredient {
  final String name;
  final String size;

  Ingredient({required this.name, required this.size});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      size: json['size'] ?? '',
    );
  }

  static List<Ingredient> toList(List<dynamic> jsonList) {
    return jsonList.map((item) => Ingredient.fromJson(item)).toList();
  }
}
