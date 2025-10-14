# Chức Năng NFC - Hướng Dẫn Đầy Đủ

## 📋 Tổng Quan

Ứng dụng hỗ trợ đầy đủ chức năng **GHI** và **ĐỌC** thẻ NFC để lưu trữ và truy xuất thông tin từ vựng.

## 🎯 Các Chức Năng

### 1. GHI VÀO THẺ NFC (WriteScreen)

**Màn hình**: `lib/screens/write_screen.dart`

**Chức năng**:
- Chọn từ vựng từ danh sách
- Ghi thông tin từ vào thẻ NFC
- Hiển thị chi tiết từ đã chọn

**Luồng hoạt động**:
```
1. Mở tab "Ghi" trong ứng dụng
2. Chọn một từ vựng từ danh sách
3. Nhấn nút "Ghi vào thẻ NFC"
4. Đưa thẻ NFC lại gần điện thoại
5. Thành công → Hiển thị thông báo "✅ Ghi thành công"
```

**Format dữ liệu ghi vào thẻ**:
```
EN:english_word|VN:vietnamese_translation|IMG:image_path
```

**Ví dụ**:
```
EN:apple|VN:táo|IMG:assets/images/apple.jpg
```

**Validation**:
- ✅ Kiểm tra NFC có khả dụng
- ✅ Kiểm tra thẻ có hỗ trợ NDEF
- ✅ Kiểm tra thẻ có thể ghi (writable)
- ✅ Kiểm tra dung lượng thẻ (maxSize)
- ✅ Xử lý lỗi và hiển thị thông báo rõ ràng

**UI Features**:
- Danh sách từ vựng với scroll
- Highlight từ đã chọn (màu hồng)
- Hiển thị card chi tiết của từ đã chọn
- Loading indicator khi đang ghi
- SnackBar thông báo kết quả

---

### 2. ĐỌC THẺ NFC (ScanScreen)

**Màn hình**: `lib/screens/scan_screen.dart`

**Chức năng**:
- Quét thẻ NFC để đọc thông tin từ vựng
- Chụp ảnh để nhận diện hoa quả (AI)
- Hiển thị chi tiết từ sau khi đọc/nhận diện

**Luồng hoạt động quét NFC**:
```
1. Mở tab "Nhận diện" trong ứng dụng
2. Nhấn nút "Quét thẻ NFC" (màu xanh dương)
3. Đưa thẻ NFC lại gần điện thoại
4. Thành công → Hiển thị thông tin từ vựng với:
   - Hình ảnh
   - Tên tiếng Anh
   - Tên tiếng Việt
   - Phát âm (audio)
```

**Parse dữ liệu từ thẻ**:
```dart
// Input: "EN:apple|VN:táo|IMG:assets/images/apple.jpg"
// Output:
{
  'EN': 'apple',
  'VN': 'táo',
  'IMG': 'assets/images/apple.jpg'
}
```

**Validation**:
- ✅ Kiểm tra NFC có khả dụng
- ✅ Kiểm tra thẻ có hỗ trợ NDEF
- ✅ Kiểm tra thẻ có dữ liệu
- ✅ Parse và validate format dữ liệu
- ✅ Tìm từ trong database (nếu có)
- ✅ Fallback tạo WordData tạm nếu không tìm thấy

**UI Features**:
- 2 nút: "Quét thẻ NFC" (xanh) và "Chụp ảnh nhận diện" (nâu)
- Loading indicator khi đang quét
- Thông báo "Đang chờ thẻ NFC..."
- Hiển thị card chi tiết sau khi đọc thành công
- Error messages rõ ràng

---

## 🔧 Cấu Trúc Code

### NfcService (`lib/utils/nfc.dart`)
**Mục đích**: Utility functions cho NFC (hiện chưa sử dụng)

### WriteScreen Implementation

**Key Methods**:
```dart
Future<void> _writeToNFC() async {
  // 1. Kiểm tra word đã chọn
  // 2. Kiểm tra NFC available
  // 3. Tạo data string
  // 4. Start NFC session
  // 5. Kiểm tra NDEF support
  // 6. Kiểm tra writable
  // 7. Kiểm tra capacity
  // 8. Create NDEF message
  // 9. Write to tag
  // 10. Show success/error
}
```

**State Variables**:
- `selectedWord`: Từ được chọn để ghi
- `_isWriting`: Trạng thái đang ghi
- `wordList`: Danh sách tất cả từ vựng

### ScanScreen Implementation

**Key Methods**:
```dart
Future<void> _scanNFC() async {
  // 1. Kiểm tra NFC available
  // 2. Start NFC session
  // 3. Read NDEF message
  // 4. Parse payload (bỏ language code)
  // 5. Parse data format "KEY:VALUE|KEY:VALUE"
  // 6. Tìm từ trong database
  // 7. Hiển thị kết quả
}

Future<void> _captureImage() async {
  // AI image recognition (existing feature)
}
```

**State Variables**:
- `isScanningNFC`: Trạng thái đang quét NFC
- `isProcessingImage`: Trạng thái đang xử lý ảnh
- `matchedWord`: Từ vựng tìm được
- `_nfcMessage`: Thông báo trạng thái NFC
- `_errorMessage`: Thông báo lỗi

---

## 📱 Cách Sử Dụng

### Ghi Thẻ NFC

1. **Chuẩn bị**:
   - Có thẻ NFC trống hoặc có thể ghi
   - Bật NFC trên điện thoại

2. **Các bước**:
   ```
   Mở app → Tab "Ghi"
   ↓
   Chọn từ vựng từ danh sách (ví dụ: "apple")
   ↓
   Nhấn "Ghi vào thẻ NFC"
   ↓
   Thông báo: "Đang chờ thẻ NFC... Vui lòng đưa thẻ lại gần!"
   ↓
   Đưa thẻ NFC lại gần điện thoại (phía sau)
   ↓
   Thành công: "✅ Ghi thành công từ 'apple'!"
   ```

3. **Lưu ý**:
   - Giữ thẻ sát điện thoại 2-3 giây
   - Không di chuyển cho đến khi có thông báo
   - Nếu lỗi, thử lại hoặc dùng thẻ khác

### Đọc Thẻ NFC

1. **Chuẩn bị**:
   - Có thẻ NFC đã ghi dữ liệu
   - Bật NFC trên điện thoại

2. **Các bước**:
   ```
   Mở app → Tab "Nhận diện"
   ↓
   Nhấn "Quét thẻ NFC" (nút màu xanh)
   ↓
   Thông báo: "Đang chờ thẻ NFC... Vui lòng đưa thẻ lại gần!"
   ↓
   Đưa thẻ NFC lại gần điện thoại
   ↓
   Hiển thị thông tin từ vựng với hình ảnh và âm thanh
   ```

3. **Lưu ý**:
   - Có thể đọc nhiều lần
   - Mỗi lần đọc sẽ replace kết quả cũ
   - Có thể chuyển sang chụp ảnh nhận diện AI

---

## 🐛 Xử Lý Lỗi

### Lỗi Thường Gặp

| Lỗi | Nguyên Nhân | Giải Pháp |
|-----|-------------|-----------|
| "NFC không khả dụng" | Điện thoại không hỗ trợ NFC hoặc chưa bật | Bật NFC trong Settings |
| "Thẻ không hỗ trợ NDEF" | Thẻ NFC không đúng loại | Dùng thẻ NFC Type 2, 4 hoặc 5 |
| "Thẻ không thể ghi" | Thẻ bị khóa hoặc read-only | Dùng thẻ khác có thể ghi |
| "Dữ liệu quá lớn" | Thẻ không đủ dung lượng | Dùng thẻ có dung lượng lớn hơn |
| "Thẻ trống" | Thẻ chưa có dữ liệu | Ghi dữ liệu trước khi đọc |
| "Dữ liệu không đúng định dạng" | Dữ liệu bị lỗi hoặc không phải app ghi | Ghi lại từ app |

### Error Messages

**WriteScreen**:
- ✅ User-friendly messages
- ✅ SnackBar với màu đỏ/xanh
- ✅ Stop session với error message

**ScanScreen**:
- ✅ Hiển thị lỗi ở giữa màn hình
- ✅ Màu đỏ cho errors
- ✅ Màu xanh cho thông báo đang quét

---

## 🔐 Bảo Mật & Giới Hạn

### Bảo Mật
- ⚠️ Dữ liệu **KHÔNG mã hóa** trên thẻ
- ⚠️ Bất kỳ ai có thẻ đều đọc được
- ✅ Chỉ lưu thông tin công khai (từ vựng)
- ✅ Không lưu thông tin nhạy cảm

### Giới Hạn
- **Dung lượng thẻ**: Thường 48-888 bytes
- **Format**: Chỉ hỗ trợ NDEF Text Record
- **Compatibility**: Android only (iOS có hạn chế)
- **Distance**: Cần giữ thẻ < 4cm từ điện thoại

---

## 📊 Technical Details

### NDEF Format

**Cấu trúc NDEF Message**:
```
NdefMessage {
  records: [
    NdefRecord {
      typeNameFormat: NfcWellknown
      type: "T" (Text)
      payload: [
        0x02,              // Language code length + encoding
        0x65, 0x6E,        // "en" language code
        ...text bytes...   // UTF-8 encoded text
      ]
    }
  ]
}
```

**Parse Payload**:
```dart
int languageCodeLength = payload[0] & 0x3F; // 6 bits thấp
int textStart = 1 + languageCodeLength;     // Bỏ qua language code
String text = String.fromCharCodes(payload.sublist(textStart));
```

### Package Used
```yaml
dependencies:
  nfc_manager: ^3.5.0
```

### Permissions (Android)

**AndroidManifest.xml**:
```xml
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />
```

---

## ✅ Testing Checklist

### Ghi Thẻ NFC
- [ ] Chọn được từ vựng
- [ ] Nhấn nút "Ghi vào thẻ NFC"
- [ ] Hiển thị loading indicator
- [ ] Ghi thành công vào thẻ NTAG213/215/216
- [ ] Hiển thị thông báo thành công
- [ ] Reset selection sau khi ghi
- [ ] Xử lý lỗi thẻ không hỗ trợ
- [ ] Xử lý lỗi thẻ đầy

### Đọc Thẻ NFC
- [ ] Nhấn nút "Quét thẻ NFC"
- [ ] Hiển thị loading indicator
- [ ] Đọc được thẻ đã ghi từ app
- [ ] Parse đúng format dữ liệu
- [ ] Tìm được từ trong database
- [ ] Hiển thị WordDisplay với đầy đủ thông tin
- [ ] Phát được âm thanh (audio)
- [ ] Xử lý lỗi thẻ trống
- [ ] Xử lý lỗi format không hợp lệ

### Tích Hợp
- [ ] 2 tab hoạt động độc lập
- [ ] Không conflict giữa Ghi và Đọc
- [ ] State management đúng
- [ ] Không memory leak (dispose đúng cách)

---

## 🚀 Future Improvements

### Có Thể Thêm
1. **Ghi nhiều từ**: Lưu nhiều từ trên một thẻ
2. **QR Code**: Export/Import từ vựng qua QR
3. **NFC History**: Lịch sử ghi/đọc
4. **Tag Info**: Hiển thị thông tin thẻ (ID, capacity, technology)
5. **Write Lock**: Khóa thẻ sau khi ghi
6. **Batch Write**: Ghi hàng loạt từ vào nhiều thẻ
7. **Statistics**: Thống kê số lần đọc từng từ

### Tối Ưu
1. **Caching**: Cache danh sách từ vựng
2. **Compression**: Nén dữ liệu trước khi ghi
3. **Encryption**: Mã hóa dữ liệu (nếu cần)
4. **Offline Mode**: Hoạt động hoàn toàn offline

---

## 📚 Related Files

### Core Files
- `lib/screens/write_screen.dart` - Ghi NFC
- `lib/screens/scan_screen.dart` - Đọc NFC
- `lib/utils/nfc.dart` - NFC utilities
- `lib/Models/WordData.dart` - Word model
- `lib/widgets/word_display.dart` - Display widget

### Dependencies
- `pubspec.yaml` - Package nfc_manager
- `android/app/src/main/AndroidManifest.xml` - NFC permissions

---

**Ngày cập nhật**: 6 tháng 10, 2025  
**Tác giả**: GitHub Copilot  
**Version**: 2.0.0
