class Car {
  String id;
  String title;
  String description;
  List<String> tags;
  List<String> imageUrls;
  String ownerId;
  List<String> searchKeywords; // New field for search optimization

  Car({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.imageUrls,
    required this.ownerId,
    required this.searchKeywords,
  });

  // Convert Car object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'searchKeywords': searchKeywords,
    };
  }

  // Create Car object from Firestore document
  factory Car.fromMap(String id, Map<String, dynamic> data) {
    return Car(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      ownerId: data['ownerId'] ?? '',
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }
}
