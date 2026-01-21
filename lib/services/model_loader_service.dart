import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ModelLoaderService {
  static const String _modelAssetPath = 'assets/models/ggml-base.en.bin';
  static const String _modelFileName = 'ggml-base.en.bin';

  Future<String> ensureModelAvailable() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDir.path}/$_modelFileName';
    final modelFile = File(modelPath);

    if (await modelFile.exists()) {
      return modelPath;
    }

    try {
      final ByteData data = await rootBundle.load(_modelAssetPath);
      final bytes = data.buffer.asUint8List();
      await modelFile.writeAsBytes(bytes);
      return modelPath;
    } catch (e) {
      throw Exception('Failed to load model: $e. Make sure the model file is in assets/models/');
    }
  }

  Future<String> getModelPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$_modelFileName';
  }

  Future<bool> modelExists() async {
    final modelPath = await getModelPath();
    return await File(modelPath).exists();
  }
}

