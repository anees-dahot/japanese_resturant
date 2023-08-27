class Items {
  final String name;
  final String price;
  final String imageUrl;
  final String rating;


  Items({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,

  });

 String get _name => name;
 String get _price => price;
 String get _imageUrl => imageUrl;
 String get _rating => rating;

}
