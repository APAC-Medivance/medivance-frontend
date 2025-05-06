import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hajjhealth/view/users/Home/medibot.dart';

import '../firebase_options.dart';

part 'gemini.g.dart';

@riverpod
Future<FirebaseApp> firebaseApp(Ref ref) =>
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

@riverpod
Future<GenerativeModel> geminiModel(Ref ref) async {
  await ref.watch(firebaseAppProvider.future);

  final model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-2.0-flash',
  );
  return model;
}

final chatStateNotifierProvider =
    StateNotifierProvider<ChatStateNotifier, List<ChatMessage>>((ref) {
      return ChatStateNotifier();
    });

class ChatStateNotifier extends StateNotifier<List<ChatMessage>> {
  ChatStateNotifier() : super([]);

  void addUserMessage(String message) {
    final id = DateTime.now().toIso8601String(); // Buat ID unik
    state = [...state, ChatMessage(id: id, text: message, isUser: true)];
  }

  ChatMessage createLlmMessage() {
    final id = DateTime.now().toIso8601String(); // Buat ID unik
    final message = ChatMessage(id: id, text: '', isUser: false);
    state = [...state, message];
    return message;
  }

  void appendToMessage(String id, String response) {
    state = state.map((message) {
      if (message.id == id) {
        return ChatMessage(
          id: message.id,
          text: message.text + response,
          isUser: message.isUser,
        );
      }
      return message;
    }).toList();
  }

  void finalizeMessage(String id) {
    // Tambahkan logika jika diperlukan
    print("Message with id $id has been finalized.");
  }
}

final logStateNotifierProvider =
    StateNotifierProvider<LogStateNotifier, List<String>>((ref) {
      return LogStateNotifier();
    });

class LogStateNotifier extends StateNotifier<List<String>> {
  LogStateNotifier() : super([]);

  void logUserText(String text) {
    state = [...state, "User: $text"];
  }

  void logLlmText(String text) {
    state = [...state, "Bot: $text"];
  }

  void logError(Object error, {StackTrace? st}) {
    state = [...state, "Error: $error"];
  }
}

@Riverpod(keepAlive: true)
Future<ChatSession> chatSession(Ref ref) async {
  final model = await ref.watch(geminiModelProvider.future);
  return model.startChat();
}
