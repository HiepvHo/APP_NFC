import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Script để tạo dữ liệu user mẫu trong MongoDB
Future<void> seedUsers() async {
  final db = await Db.create(
      'mongodb+srv://hvhhhta1:mPYTbvj5cOolUUWf@hiep.lezxu.mongodb.net/nfc_words?retryWrites=true&w=majority&appName=Hiep');
  
  await db.open();
  print('✅ Đã kết nối MongoDB');
  
  final collection = db.collection('users');

  // Hàm hash password
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Xóa dữ liệu cũ (nếu có)
  await collection.remove({});
  print('🗑️  Đã xóa dữ liệu user cũ');

  // Tạo các user mẫu
  final users = [
    {
      "_id": ObjectId(),
      "username": "admin",
      "email": "admin@example.com",
      "password": hashPassword("123456"), // Password: 123456
      "fullName": "Administrator",
      "createdAt": DateTime.now().toIso8601String(),
    },
    {
      "_id": ObjectId(),
      "username": "user1",
      "email": "user1@example.com",
      "password": hashPassword("123456"), // Password: 123456
      "fullName": "Nguyễn Văn A",
      "createdAt": DateTime.now().toIso8601String(),
    },
    {
      "_id": ObjectId(),
      "username": "user2",
      "email": "user2@example.com",
      "password": hashPassword("123456"), // Password: 123456
      "fullName": "Trần Thị B",
      "createdAt": DateTime.now().toIso8601String(),
    },
    {
      "_id": ObjectId(),
      "username": "testuser",
      "email": "test@example.com",
      "password": hashPassword("password"), // Password: password
      "fullName": "Test User",
      "createdAt": DateTime.now().toIso8601String(),
    },
  ];

  // Insert users vào database
  for (var user in users) {
    await collection.insert(user);
    print('✅ Đã tạo user: ${user['username']} (${user['email']})');
  }

  print('\n🎉 Seeding hoàn tất! Đã tạo ${users.length} users');
  print('\n📝 Thông tin đăng nhập mẫu:');
  print('   Email: admin@example.com | Password: 123456');
  print('   Email: user1@example.com | Password: 123456');
  print('   Email: user2@example.com | Password: 123456');
  print('   Email: test@example.com  | Password: password');
  
  await db.close();
  print('\n✅ Đã đóng kết nối MongoDB');
}
