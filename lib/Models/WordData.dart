class WordData {
  WordData({
    required this.id,
    required this.en,
    required this.vn,
    required this.audioEn,
    required this.audioVn,
    required this.image,
  });

  final int? id;
  final String? en;
  final String? vn;
  final String? audioEn;
  final String? audioVn;
  final String? image;

  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      id: json["id"],
      en: json["en"],
      vn: json["vn"],
      audioEn: json["audioEn"],
      audioVn: json["audioVn"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "en": en,
        "vn": vn,
        "audioEn": audioEn,
        "audioVn": audioVn,
        "image": image,
      };
}
