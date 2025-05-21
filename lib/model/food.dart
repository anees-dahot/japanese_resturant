class Items {
  final String? id;
  final String name;
  final double price;
  final String imageUrl;
  final String rating;
  final String? description;
  final String? category;

  Items({
    this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    this.description,
    this.category,
  });

  // Getters (optional, but shown for consistency with original structure)
  String? get _id => id;
  String get _name => name;
  double get _price => price;
  String get _imageUrl => imageUrl;
  String get _rating => rating;
  String? get _description => description;
  String? get _category => category;
}
