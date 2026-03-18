class ProductImage {
  final String id;
  final String url;
  final bool isPrimary;
  final int sortOrder;

  const ProductImage({
    required this.id,
    required this.url,
    required this.isPrimary,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: json['id'] as String,
        url: json['url'] as String,
        isPrimary: json['isPrimary'] as bool? ?? false,
        sortOrder: json['sortOrder'] as int? ?? 0,
      );
}

class Product {
  final String id;
  final String reference;
  final String name;
  final String category;
  final String? description;
  final double unitPrice;
  final double? bulkPrice;
  final int? bulkMinQuantity;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? weightKg;
  final String status;
  final List<String> usages;
  final List<ProductImage> images;
  final int? availableStock;

  const Product({
    required this.id,
    required this.reference,
    required this.name,
    required this.category,
    this.description,
    required this.unitPrice,
    this.bulkPrice,
    this.bulkMinQuantity,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.weightKg,
    required this.status,
    required this.usages,
    required this.images,
    this.availableStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final inventory = json['inventory'] as List<dynamic>? ?? [];
    int? stock;
    if (inventory.isNotEmpty) {
      stock = inventory.fold<int>(0, (sum, inv) => sum + ((inv['available'] as int?) ?? 0));
    }

    return Product(
      id: json['id'] as String,
      reference: json['reference'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      bulkPrice: (json['bulkPrice'] as num?)?.toDouble(),
      bulkMinQuantity: json['bulkMinQuantity'] as int?,
      lengthCm: (json['lengthCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      status: json['status'] as String,
      usages: List<String>.from(json['usages'] as List<dynamic>? ?? []),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableStock: stock,
    );
  }

  bool get inStock => (availableStock ?? 0) > 0;

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.where((i) => i.isPrimary).toList();
    return primary.isNotEmpty ? primary.first.url : images.first.url;
  }

  String get dimensionsLabel {
    if (lengthCm != null && widthCm != null && heightCm != null) {
      return '${lengthCm!.toInt()} × ${widthCm!.toInt()} × ${heightCm!.toInt()} cm';
    }
    return '';
  }
}

class ProductsPage {
  final List<Product> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const ProductsPage({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ProductsPage.fromJson(Map<String, dynamic> json) => ProductsPage(
        data: (json['data'] as List<dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
      );
}
