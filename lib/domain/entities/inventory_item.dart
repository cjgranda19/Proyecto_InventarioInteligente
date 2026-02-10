class InventoryItem {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String? imageUrl;
  final String? localImagePath;
  final int quantity;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? expirationDate;
  final DateTime? maintenanceDate;
  final String? barcode;
  final String? qrCode;
  final List<String> tags;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.imageUrl,
    this.localImagePath,
    this.quantity = 1,
    this.location,
    this.latitude,
    this.longitude,
    this.expirationDate,
    this.maintenanceDate,
    this.barcode,
    this.qrCode,
    this.tags = const [],
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? imageUrl,
    String? localImagePath,
    int? quantity,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? expirationDate,
    DateTime? maintenanceDate,
    String? barcode,
    String? qrCode,
    List<String>? tags,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      expirationDate: expirationDate ?? this.expirationDate,
      maintenanceDate: maintenanceDate ?? this.maintenanceDate,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      tags: tags ?? this.tags,
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
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'quantity': quantity,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'expirationDate': expirationDate?.toIso8601String(),
      'maintenanceDate': maintenanceDate?.toIso8601String(),
      'barcode': barcode,
      'qrCode': qrCode,
      'tags': tags,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String,
      imageUrl: json['imageUrl'] as String?,
      localImagePath: json['localImagePath'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      maintenanceDate: json['maintenanceDate'] != null
          ? DateTime.parse(json['maintenanceDate'] as String)
          : null,
      barcode: json['barcode'] as String?,
      qrCode: json['qrCode'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
    );
  }
}
