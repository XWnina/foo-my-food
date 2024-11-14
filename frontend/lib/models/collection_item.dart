class CollectionItem {
  final int id;
  final String name;
  final int calories;
  final String? imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> tags;


  CollectionItem({
    required this.id,
    required this.name,
    required this.calories,
    this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.tags,
  });

  // 从 Map 创建 CollectionItem 实例
  factory CollectionItem.fromMap(Map<String, dynamic> map) {
    return CollectionItem(
      id: map['id'] ?? 0,
      name: map['dishName'] ?? 'Unnamed',
      calories: map['calories'] ?? 0,
      imageUrl: map['imageURL'],
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredientsAsList'] ?? []),
      tags: map['labels'] != null
          ? map['labels'].split(',') // 将逗号分隔的字符串转换为 List
          : [],
    );
  }

  // 转换为 Map（例如发送到后端或存储时使用）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dishName': name,
      'calories': calories,
      'imageURL': imageUrl,
      'description': description,
      'ingredientsAsList': ingredients,
      'labels': tags.join(','), // 将标签列表转换为逗号分隔的字符串
    };
  }
}
