import 'package:nfc_01/utils/db_seed.dart';

void main() async {
  print('Starting database seeding...');
  try {
    await seedDatabase();
    print('Database seeding completed successfully!');
  } catch (e) {
    print('Error seeding database: $e');
  }
}
