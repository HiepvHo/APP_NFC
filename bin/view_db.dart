import 'package:mongo_dart/mongo_dart.dart';

/// Script để xem dữ liệu trong MongoDB
/// Chạy: dart run bin/view_db.dart
void main() async {
  print('🔍 Đang kết nối MongoDB...\n');

  final db = await Db.create(
      'mongodb+srv://hvhhhta1:mPYTbvj5cOolUUWf@hiep.lezxu.mongodb.net/nfc_words?retryWrites=true&w=majority&appName=Hiep');

  await db.open();
  print('✅ Đã kết nối MongoDB\n');

  // Xem tất cả users
  print('=' * 60);
  print('👥 DANH SÁCH USERS');
  print('=' * 60);
  
  final usersCollection = db.collection('users');
  final users = await usersCollection.find().toList();

  if (users.isEmpty) {
    print('❌ Không có user nào trong database');
  } else {
    print('Tổng số users: ${users.length}\n');
    
    for (var i = 0; i < users.length; i++) {
      var user = users[i];
      print('${i + 1}. User:');
      print('   ID: ${user['_id']}');
      print('   Username: ${user['username']}');
      print('   Email: ${user['email']}');
      print('   Full Name: ${user['fullName'] ?? 'N/A'}');
      print('   Created: ${user['createdAt']}');
      print('   Password (hashed): ${user['password'].substring(0, 20)}...');
      print('');
    }
  }

  // Xem tất cả words
  print('=' * 60);
  print('📚 DANH SÁCH TỪ VỰNG');
  print('=' * 60);
  
  final wordsCollection = db.collection('words');
  final words = await wordsCollection.find().toList();

  if (words.isEmpty) {
    print('❌ Không có từ vựng nào trong database');
  } else {
    print('Tổng số từ: ${words.length}\n');
    
    for (var i = 0; i < words.length; i++) {
      var word = words[i];
      print('${i + 1}. Word:');
      print('   ID: ${word['id']}');
      print('   English: ${word['en']}');
      print('   Vietnamese: ${word['vn']}');
      print('   Image: ${word['image']}');
      print('');
    }
  }

  print('=' * 60);
  print('✅ Hoàn tất!');
  
  await db.close();
  print('✅ Đã đóng kết nối MongoDB');
}
