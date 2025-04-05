// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Object Detection with YOLOv8',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ObjectDetectionScreen(),
//     );
//   }
// }

// class ObjectDetectionScreen extends StatefulWidget {
//   @override
//   _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
// }

// class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
//   late File _image;
//   bool _isImageSelected = false;
//   String _resultText = 'No objects detected yet.';
//   late Interpreter _interpreter;

//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }

//   // Tải mô hình TensorFlow Lite
//   Future<void> _loadModel() async {
//     _interpreter = await Interpreter.fromAsset('assets/yolov8n.tflite');
//   }

//   // Chọn ảnh từ thư viện hoặc camera
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _isImageSelected = true;
//       });
//       _detectObjects(_image);
//     }
//   }

//   // Nhận diện đối tượng trong ảnh sử dụng TensorFlow Lite
//   Future<void> _detectObjects(File image) async {
//     final img.Image imageFile = img.decodeImage(image.readAsBytesSync())!;
//     final inputImage = imageFile.getBytes();

//     // Chuyển đổi ảnh thành định dạng phù hợp với TensorFlow Lite
//     final imgSize = 640;  // Kích thước ảnh đầu vào của YOLOv8 (640x640)
//     final input = img.Image(imgSize, imgSize);
//     input.data.setRange(0, inputImage.length, inputImage);

//     // Dự đoán đối tượng
//     final output = List.generate(1, (index) => List.filled(10, 0));

//     _interpreter.run(input, output);

//     setState(() {
//       _resultText = 'Objects detected: \n';
//       for (var i = 0; i < output.length; i++) {
//         _resultText += 'Label ${i + 1}: ${output[i]} \n';
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _interpreter.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Object Detection with YOLOv8'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_isImageSelected)
//               Image.file(
//                 _image,
//                 width: 300,
//                 height: 300,
//                 fit: BoxFit.cover,
//               )
//             else
//               Text('No image selected.'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: Text('Select Image'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               _resultText,
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
