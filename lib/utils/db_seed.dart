import 'package:mongo_dart/mongo_dart.dart';

Future<void> seedDatabase() async {
  final db = await Db.create(
      'mongodb+srv://hvhhhta1:mPYTbvj5cOolUUWf@hiep.lezxu.mongodb.net/nfc_words?retryWrites=true&w=majority&appName=Hiep');
  await db.open();
  final collection = db.collection('words');

  final words = [
    {
      "id": 1,
      "en": "apple",
      "vn": "quả táo",
      "audioEn": "assets/audio/en/apple.mp3",
      "audioVn": "assets/audio/vn/apple.mp3",
      "image": "assets/images/apple.jpg"
    },
    {
      "id": 2,
      "en": "banana",
      "vn": "quả chuối",
      "audioEn": "assets/audio/en/banana.mp3",
      "audioVn": "assets/audio/vn/banana.mp3",
      "image": "assets/images/banana.jpg"
    },
    {
      "id": 3,
      "en": "grape",
      "vn": "quả nho",
      "audioEn": "assets/audio/en/grape.mp3",
      "audioVn": "assets/audio/vn/grape.mp3",
      "image": "assets/images/grape.jpg"
    },
    {
      "id": 4,
      "en": "orange",
      "vn": "quả cam",
      "audioEn": "assets/audio/en/orange.mp3",
      "audioVn": "assets/audio/vn/orange.mp3",
      "image": "assets/images/orange.jpg"
    },
    {
      "id": 5,
      "en": "guava",
      "vn": "quả ổi",
      "audioEn": "assets/audio/en/guava.mp3",
      "audioVn": "assets/audio/vn/guava.mp3",
      "image": "assets/images/guava.jpg"
    },
    {
      "id": 6,
      "en": "mango",
      "vn": "quả xoài",
      "audioEn": "assets/audio/en/mango.mp3",
      "audioVn": "assets/audio/vn/mango.mp3",
      "image": "assets/images/mango.jpg"
    },
    {
      "id": 7,
      "en": "watermelon",
      "vn": "quả dưa hấu",
      "audioEn": "assets/audio/en/watermelon.mp3",
      "audioVn": "assets/audio/vn/watermelon.mp3",
      "image": "assets/images/watermelon.jpg"
    }
  ];

  // Clear existing data
  await collection.remove({});

  // Insert new data
  for (var word in words) {
    await collection.insert(word);
  }

  print('Database seeded successfully!');
  await db.close();
}
