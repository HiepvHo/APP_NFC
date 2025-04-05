import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  // Đọc dữ liệu từ thẻ NFC
  Future<String> readTag() async {
    String result = '';
    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result = 'Tag không hỗ trợ NDEF';
        await NfcManager.instance.stopSession(errorMessage: result);
        return;
      }

      try {
        var ndefMessage = await ndef.read();
        result = ndefMessage?.records
                .map((e) => String.fromCharCodes(e.payload))
                .join("\n") ??
            "Không có dữ liệu";
        await NfcManager.instance.stopSession();
      } catch (e) {
        result = 'Lỗi khi đọc thẻ: $e';
        await NfcManager.instance.stopSession(errorMessage: result);
      }
    });

    return result;
  }

  // Ghi dữ liệu vào thẻ NFC
  Future<String> writeTag(String textToWrite) async {
    if (textToWrite.isEmpty) {
      return 'Vui lòng nhập văn bản để ghi vào thẻ!';
    }

    String result = '';
    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result = 'Tag không hỗ trợ NDEF hoặc không thể ghi!';
        await NfcManager.instance.stopSession(errorMessage: result);
        return;
      }

      NdefMessage message = NdefMessage([NdefRecord.createText(textToWrite)]);

      try {
        await ndef.write(message);
        result = 'Ghi thành công: $textToWrite';
        await NfcManager.instance.stopSession();
      } catch (e) {
        result = 'Lỗi khi ghi thẻ: $e';
        await NfcManager.instance.stopSession(errorMessage: result);
      }
    });

    return result;
  }
}
