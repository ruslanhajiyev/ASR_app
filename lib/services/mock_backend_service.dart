import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';

class MockBackendService {
  static const String _usersPath = 'assets/mock_backend/users.json';
  static const String _tokensPath = 'assets/mock_backend/tokens.json';
  static const String _submissionsPath = 'assets/mock_backend/submissions.json';

  List<Map<String, dynamic>> _users = [];
  Map<String, String> _tokens = {}; 
  List<Map<String, dynamic>> _submissions = [];

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      final usersString = await rootBundle.loadString(_usersPath);
      _users = List<Map<String, dynamic>>.from(
        json.decode(usersString) as List,
      );

      try {
        final tokensString = await rootBundle.loadString(_tokensPath);
        final tokensData = json.decode(tokensString) as Map<String, dynamic>;
        _tokens = Map<String, String>.from(
          tokensData.map((key, value) => MapEntry(key, value.toString())),
        );
      } catch (e) {
        _tokens = {};
      }

      try {
        final directory = await getApplicationDocumentsDirectory();
        final tokensFile = File('${directory.path}/tokens.json');
        if (await tokensFile.exists()) {
          final tokensString = await tokensFile.readAsString();
          final tokensData = json.decode(tokensString) as Map<String, dynamic>;
          _tokens.addAll(Map<String, String>.from(
            tokensData.map((key, value) => MapEntry(key, value.toString())),
          ));
        }
      } catch (e) {
        // Ignore errors loading runtime tokens
      }

      try {
        final directory = await getApplicationDocumentsDirectory();
        final submissionsFile = File('${directory.path}/submissions.json');
        if (await submissionsFile.exists()) {
          final submissionsString = await submissionsFile.readAsString();
          _submissions = List<Map<String, dynamic>>.from(
            json.decode(submissionsString) as List,
          );
        } else {
          try {
            final submissionsString =
                await rootBundle.loadString(_submissionsPath);
            _submissions = List<Map<String, dynamic>>.from(
              json.decode(submissionsString) as List,
            );
          } catch (e) {
            _submissions = [];
          }
        }
      } catch (e) {
        try {
          final submissionsString =
              await rootBundle.loadString(_submissionsPath);
          _submissions = List<Map<String, dynamic>>.from(
            json.decode(submissionsString) as List,
          );
        } catch (e2) {
          _submissions = [];
        }
      }

      _initialized = true;
    } catch (e) {
      // If files don't exist, start with empty data
      _users = [];
      _tokens = {};
      _submissions = [];
      _initialized = true;
    }
  }

  Future<void> _saveTokens() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tokens.json');
      await file.writeAsString(json.encode(_tokens));
    } catch (e) {
      // Ignore errors in mock service
    }
  }

  Future<void> _saveSubmissions() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/submissions.json');
      final jsonString = json.encode(_submissions);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving submissions: $e');
      // Re-throw to ensure we know if saving fails
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String username,
    required String password,
    required String email,
  }) async {
    await _initialize();

    if (_users.any((u) => u['username'] == username)) {
      throw Exception('Username already exists');
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'username': username,
      'password': password, 
      'email': email,
    };

    _users.add(newUser);

    final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
    _tokens[token] = newUser['id'] as String;
    await _saveTokens();

    final user = User.fromJson(newUser);
    return AuthResponse(
      accessToken: token,
      user: user,
    );
  }

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    await _initialize();

    final userData = _users.firstWhere(
      (u) => u['username'] == username && u['password'] == password,
      orElse: () => throw Exception('Invalid credentials'),
    );

    final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
    _tokens[token] = userData['id'] as String;
    await _saveTokens();

    final user = User.fromJson(userData);
    return AuthResponse(
      accessToken: token,
      user: user,
    );
  }

  Future<User?> getCurrentUser(String token) async {
    await _initialize();

    final userId = _tokens[token];
    if (userId == null) return null;

    final userData = _users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => throw Exception('User not found'),
    );

    return User.fromJson(userData);
  }

  Future<void> logout(String token) async {
    await _initialize();
    _tokens.remove(token);
    await _saveTokens();
  }

  Future<Submission> createSubmission({
    required String userId,
    required SubmissionType type,
    required String transcriptFinal,
    String? transcriptDraft,
    List<String>? labels,
    String? audioPath,
    Map<String, dynamic>? metadata,
  }) async {
    await _initialize();

    final submission = Submission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: type,
      audioPath: audioPath,
      transcriptFinal: transcriptFinal,
      transcriptDraft: transcriptDraft,
      labels: labels ?? [],
      status: SubmissionStatus.queued,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _submissions.add(submission.toJson());
    await _saveSubmissions();

    return submission;
  }

  Future<List<Submission>> getSubmissions(String userId, String token) async {
    await _initialize();

   
    try {
      final directory = await getApplicationDocumentsDirectory();
      final tokensFile = File('${directory.path}/tokens.json');
      if (await tokensFile.exists()) {
        final tokensString = await tokensFile.readAsString();
        if (tokensString.isNotEmpty) {
          final tokensData = json.decode(tokensString) as Map<String, dynamic>;
        
          _tokens = Map<String, String>.from(
            tokensData.map((key, value) => MapEntry(key, value.toString())),
          );
        }
      }
    } catch (e) {
      print('Error loading tokens in getSubmissions: $e');
    
    }

  
    final tokenUserId = _tokens[token];
    if (tokenUserId == null) {
      print('Token not found: $token');
      print('Available tokens: ${_tokens.keys}');
      throw Exception('Unauthorized: Token not found');
    }
    if (tokenUserId != userId) {
      print('Token userId mismatch: tokenUserId=$tokenUserId, userId=$userId');
      throw Exception('Unauthorized: User ID mismatch');
    }

    List<Map<String, dynamic>> submissionsFromDisk = [];
    try {
      final directory = await getApplicationDocumentsDirectory();
      final submissionsFile = File('${directory.path}/submissions.json');
      if (await submissionsFile.exists()) {
        final submissionsString = await submissionsFile.readAsString();
        if (submissionsString.isNotEmpty) {
          final decoded = json.decode(submissionsString);
          if (decoded is List) {
            submissionsFromDisk = List<Map<String, dynamic>>.from(decoded);
          }
        }
      }
    } catch (e) {
      print('Error loading submissions from disk: $e');
      submissionsFromDisk = _submissions;
    }

    _submissions = submissionsFromDisk;

    return _submissions
        .where((s) => s['userId'] == userId)
        .map((s) => Submission.fromJson(s))
        .toList();
  }

  Future<Submission> updateSubmissionStatus(
    String submissionId,
    SubmissionStatus status, {
    String? errorMessage,
  }) async {
    await _initialize();

    final index = _submissions.indexWhere((s) => s['id'] == submissionId);
    if (index == -1) {
      throw Exception('Submission not found');
    }

    final submission = Submission.fromJson(_submissions[index]);
    final updated = submission.copyWith(
      status: status,
      submittedAt: status == SubmissionStatus.uploaded
          ? DateTime.now()
          : submission.submittedAt,
      errorMessage: errorMessage,
    );

    _submissions[index] = updated.toJson();
    await _saveSubmissions();

    return updated;
  }

  Future<void> clearUserSubmissions(String userId) async {
    await _initialize();

    _submissions.removeWhere((s) => s['userId'] == userId);

    await _saveSubmissions();
  }
}
