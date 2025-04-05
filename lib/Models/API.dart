import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../Models/WordData.dart';

class Testapi {
  // Khai báo biến để lưu dữ liệu
  List<WordData> wordListReal = [];
  bool isLoading = true;
  Db? _db;
  DbCollection? _collection;

  // MongoDB connection info
  final String mongoUri =
      'mongodb+srv://hvhhhta1:mPYTbvj5cOolUUWf@hiep.lezxu.mongodb.net/nfc_words?retryWrites=true&w=majority&appName=Hiep';

  // Hàm khởi tạo kết nối MongoDB
  Future<void> _initMongoDB() async {
    if (_db == null || !(_db?.isConnected ?? false)) {
      try {
        _db = await Db.create(mongoUri);
        await _db?.open();
        _collection = _db?.collection('words');
        debugPrint('MongoDB connected successfully');
      } catch (e) {
        debugPrint('MongoDB connection error: $e');
        throw Exception('Failed to connect to MongoDB');
      }
    }
  }

  // Hàm để gán dữ liệu vào wordListReal từ MongoDB
  Future<List<WordData>> fetchWordData() async {
    try {
      await _initMongoDB();

      if (_collection == null) {
        throw Exception('MongoDB collection not initialized');
      }

      final List<Map<String, dynamic>> results =
          await _collection!.find().toList();

      // Lưu dữ liệu vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('wordList', json.encode(results));

      // Cập nhật danh sách từ vựng
      wordListReal = results.map((item) => WordData.fromJson(item)).toList();
      isLoading = false;

      return wordListReal;
    } catch (error) {
      debugPrint("Lỗi khi lấy dữ liệu từ MongoDB: $error");
      return await loadDataFromSharedPreferences();
    }
  }

  // API thêm từ mới
  Future<bool> addWord(WordData word) async {
    try {
      await _initMongoDB();
      if (_collection == null)
        throw Exception('MongoDB collection not initialized');

      await _collection!.insert(word.toJson());
      return true;
    } catch (error) {
      debugPrint("Lỗi khi thêm từ: $error");
      return false;
    }
  }

  // API cập nhật từ
  Future<bool> updateWord(WordData word) async {
    try {
      await _initMongoDB();
      if (_collection == null)
        throw Exception('MongoDB collection not initialized');

      await _collection!.update(
        where.eq('id', word.id),
        word.toJson(),
      );
      return true;
    } catch (error) {
      debugPrint("Lỗi khi cập nhật từ: $error");
      return false;
    }
  }

  // API xóa từ
  Future<bool> deleteWord(int id) async {
    try {
      await _initMongoDB();
      if (_collection == null)
        throw Exception('MongoDB collection not initialized');

      await _collection!.remove(where.eq('id', id));
      return true;
    } catch (error) {
      debugPrint("Lỗi khi xóa từ: $error");
      return false;
    }
  }

  // Hàm để gán dữ liệu từ SharedPreferences vào wordListReal nếu có
  Future<List<WordData>> loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? wordListData = prefs.getString('wordList');
    if (wordListData != null) {
      List<dynamic> jsonData = json.decode(wordListData);
      wordListReal = jsonData.map((item) => WordData.fromJson(item)).toList();
      isLoading = false;
      return wordListReal;
    } else {
      isLoading = false;
      return [];
    }
  }

  // Đóng kết nối MongoDB khi không sử dụng
  Future<void> dispose() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
  }
}
