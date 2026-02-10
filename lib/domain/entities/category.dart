class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final String? colorHex;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.colorHex,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
    );
  }
}
