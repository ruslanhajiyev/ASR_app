import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class ModelInfo {
  final WhisperModel model;
  final String name;
  final String description;
  final int sizeMB;
  final String accuracy;

  const ModelInfo({
    required this.model,
    required this.name,
    required this.description,
    required this.sizeMB,
    required this.accuracy,
  });
}

class ModelManagementService {
  static const String _selectedModelKey = 'selected_whisper_model';
  
  static final ModelManagementService _instance = ModelManagementService._internal();
  factory ModelManagementService() => _instance;
  ModelManagementService._internal();

  static const List<ModelInfo> availableModels = [
    ModelInfo(
      model: WhisperModel.tiny,
      name: 'Tiny',
      description: 'Fastest, smallest model. Good for quick transcriptions.',
      sizeMB: 75,
      accuracy: 'Low',
    ),
    ModelInfo(
      model: WhisperModel.base,
      name: 'Base',
      description: 'Balanced speed and accuracy. Recommended for most use cases.',
      sizeMB: 142,
      accuracy: 'Medium',
    ),
    ModelInfo(
      model: WhisperModel.small,
      name: 'Small',
      description: 'Better accuracy with moderate speed. Good for important transcriptions.',
      sizeMB: 466,
      accuracy: 'Good',
    ),
    ModelInfo(
      model: WhisperModel.medium,
      name: 'Medium',
      description: 'High accuracy. Slower but more precise.',
      sizeMB: 1400,
      accuracy: 'High',
    ),
    ModelInfo(
      model: WhisperModel.largeV1,
      name: 'Large',
      description: 'Best accuracy. Slowest and largest model.',
      sizeMB: 2900,
      accuracy: 'Very High',
    ),
  ];

  Future<WhisperModel> getSelectedModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelName = prefs.getString(_selectedModelKey);
      
      if (modelName != null) {
        final model = availableModels.firstWhere(
          (m) => m.name.toLowerCase() == modelName.toLowerCase(),
          orElse: () => availableModels[0], 
        );
        return model.model;
      }
      
     
      return WhisperModel.tiny;
    } catch (e) {
      print('Error getting selected model: $e');
      return WhisperModel.tiny;
    }
  }

  Future<void> setSelectedModel(WhisperModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelInfo = availableModels.firstWhere(
        (m) => m.model == model,
        orElse: () => availableModels[0],
      );
      await prefs.setString(_selectedModelKey, modelInfo.name);
    } catch (e) {
      print('Error setting selected model: $e');
    }
  }

  ModelInfo? getModelInfo(WhisperModel model) {
    try {
      return availableModels.firstWhere((m) => m.model == model);
    } catch (e) {
      return null;
    }
  }

  ModelInfo? getModelInfoByName(String name) {
    try {
      return availableModels.firstWhere(
        (m) => m.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<ModelInfo> getAllModels() {
    return List.unmodifiable(availableModels);
  }

  String formatSize(int sizeMB) {
    if (sizeMB < 1000) {
      return '$sizeMB MB';
    } else {
      final sizeGB = (sizeMB / 1000).toStringAsFixed(1);
      return '$sizeGB GB';
    }
  }
}
