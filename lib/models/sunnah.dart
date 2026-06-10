class Sunnah {
  final int id;
  final String title;
  final String category;
  final String hadith;
  final String benefit;
  final String source;
  final String? arabicText;
  final String? translation;
  bool isFavorite; // New property for favorite status

  Sunnah({
    required this.id,
    required this.title,
    required this.category,
    required this.hadith,
    required this.benefit,
    required this.source,
    this.arabicText,
    this.translation,
    this.isFavorite = false, // Default to false
  });

  factory Sunnah.fromJson(Map<String, dynamic> json) {
    return Sunnah(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      hadith: json['hadith'],
      benefit: json['benefit'],
      source: json['source'],
      arabicText: json['arabic_text'],
      translation: json['translation'],
      isFavorite:
          json['is_favorite'] ?? false, // Default to false if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'hadith': hadith,
      'benefit': benefit,
      'source': source,
      'arabic_text': arabicText,
      'translation': translation,
      'is_favorite': isFavorite,
    };
  }
}
