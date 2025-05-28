class Recipe {
  final String title;
  final String photo;
  final String calories;
  final String time;
  final String description;
  final List<ingredient> ingredients;
  final List<TutorialStep> tutorial;
  final List<Review> reviews;
  final String? steps;
  final String? ingredientsString;
  final int? difficulty_id;
  final int? food_type_id;

  Recipe({
    required this.title,
    required this.photo,
    required this.calories,
    required this.time,
    required this.description,
    required this.ingredients,
    required this.tutorial,
    required this.reviews,
    this.steps,
    this.ingredientsString,
    this.difficulty_id,
    this.food_type_id,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    print('==== [Recipe.fromJson] JSON Recebido ====');
    print(json);

    List<ingredient> parsedIngredients = [];
    String? parsedIngredientsString;

    final ingredientsData = json['ingredients'];
    if (ingredientsData != null) {
      if (ingredientsData is List) {
        print('===> Ingredientes como LISTA');
        parsedIngredients = ingredientsData.map<ingredient>((item) {
          if (item is Map<String, dynamic>) {
            return ingredient.fromJson(item);
          } else {
            return ingredient(name: item.toString(), size: "");
          }
        }).toList();
      } else if (ingredientsData is String) {
        print('===> Ingredientes como STRING');
        parsedIngredientsString = ingredientsData;
        parsedIngredients = ingredientsData
            .split(';')
            .map((item) {
              print('Parsed ingrediente: ${item.trim()}');
              return ingredient(name: item.trim(), size: "");
            })
            .where((i) => i.name.isNotEmpty)
            .toList();
      } else {
        print('===> Formato desconhecido de ingredientes');
      }
    }

    String? parsedSteps;
    if (json['steps'] != null && json['steps'].toString().trim().isNotEmpty) {
      parsedSteps = json['steps'].toString();
      print('===> Steps recebidos: ${parsedSteps.substring(0, parsedSteps.length.clamp(0, 50))}...');
    } else {
      print('===> Steps ausentes ou vazios');
    }

    return Recipe(
      title: json['name']?.toString() ?? 'Sem título',
      photo: json['photo']?.toString() ?? '',
      calories: json['calories']?.toString() ?? '0',
      time: json['minutes']?.toString() ?? '0',
      description: json['description']?.toString() ?? '',
      ingredients: parsedIngredients,
      ingredientsString: parsedIngredientsString,
      steps: parsedSteps,
      tutorial: [],
      reviews: [],
      difficulty_id: json['difficulty_id'] as int?,
      food_type_id: json['food_type_id'] as int?,
    );
  }

  Recipe copyWith({
    String? title,
    String? photo,
    String? calories,
    String? time,
    String? description,
    List<ingredient>? ingredients,
    List<TutorialStep>? tutorial,
    List<Review>? reviews,
    String? steps,
    String? ingredientsString,
    int? difficulty_id,
    int? food_type_id,
  }) {
    return Recipe(
      title: title ?? this.title,
      photo: photo ?? this.photo,
      calories: calories ?? this.calories,
      time: time ?? this.time,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      tutorial: tutorial ?? this.tutorial,
      reviews: reviews ?? this.reviews,
      steps: steps ?? this.steps,
      ingredientsString: ingredientsString ?? this.ingredientsString,
      difficulty_id: difficulty_id ?? this.difficulty_id,
      food_type_id: food_type_id ?? this.food_type_id,
    );
  }

  int get difficultyId => difficulty_id ?? 0;
  int get foodTypeId => food_type_id ?? 0;
  int get preparationMinutes => int.tryParse(time) ?? 0;

  @override
  String toString() {
    return 'Recipe(title: $title, '
        'ingredients: ${ingredients.length} itens, '
        'ingredientsString: ${ingredientsString?.substring(0, 30) ?? 'null'}, '
        'steps: ${steps?.substring(0, 30) ?? 'null'})';
  }
}

class ingredient {
  final String name;
  final String size;

  ingredient({
    required this.name,
    required this.size,
  });

  factory ingredient.fromJson(Map<String, dynamic> json) {
    print('[ingredient.fromJson] $json');
    return ingredient(
      name: json['name'] as String? ?? json['ingredient'] as String? ?? '',
      size: json['size'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'size': size,
    };
  }

  static List<ingredient> toList(List<Map<String, dynamic>> json) {
    return json
        .map((e) => ingredient(
              name: e['name'] as String? ?? e['ingredient'] as String? ?? '',
              size: e['size'] as String? ?? '',
            ))
        .toList();
  }

  @override
  String toString() {
    return 'ingredient(name: $name, size: $size)';
  }
}

class TutorialStep {
  final String step;
  final String description;

  TutorialStep({
    required this.step,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'step': step,
      'description': description,
    };
  }

  factory TutorialStep.fromJson(Map<String, dynamic> json) => TutorialStep(
        step: json['step'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  static List<TutorialStep> toList(List<Map<String, dynamic>> json) {
    return json
        .map((e) => TutorialStep(
              step: e['step'] as String? ?? '',
              description: e['description'] as String? ?? '',
            ))
        .toList();
  }
}

class Review {
  final String username;
  final String review;

  Review({
    required this.username,
    required this.review,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        review: json['review'] as String? ?? '',
        username: json['username'] as String? ?? '',
      );

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'review': review,
    };
  }

  static List<Review> toList(List<Map<String, dynamic>> json) {
    return json
        .map((e) => Review(
              username: e['username'] as String? ?? '',
              review: e['review'] as String? ?? '',
            ))
        .toList();
  }
}
