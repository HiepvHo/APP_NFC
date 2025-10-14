import 'package:nfc_01/utils/seed_users.dart';

/// Script để chạy seeding users vào MongoDB
void main() async {
  print('🚀 Bắt đầu seeding users vào MongoDB...\n');
  
  try {
    await seedUsers();
    print('\n✅ Seeding thành công!');
  } catch (e) {
    print('\n❌ Lỗi khi seeding: $e');
  }
}
