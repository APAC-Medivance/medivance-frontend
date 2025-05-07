import 'dart:async';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/gemini.dart';

part 'gemini_chat_service.g.dart';

class ChatStateNotifier {
  final List<String> userMessages = [];
  final List<String> llmMessages = [];

  void addUserMessage(String message) {
    userMessages.add(message);
  }

  void appendToMessage(String id, String responseText) {
    llmMessages.add(responseText);
  }

  void finalizeMessage(String id) {
    // Finalize logic here
  }

  LlmMessage createLlmMessage() {
    return LlmMessage(id: "unique_id");
  }
}

class LogStateNotifier {
  void logUserText(String message) {
    print("User: $message");
  }

  void logLlmText(String message) {
    print("LLM: $message");
  }

  void logError(Object error, {StackTrace? st}) {
    print("Error: $error");
    if (st != null) {
      print("StackTrace: $st");
    }
  }
}

class LlmMessage {
  final String id;
  LlmMessage({required this.id});
}

class GeminiChatService {
  GeminiChatService(this.ref, this.chatStateNotifier, this.logStateNotifier);
  final Ref ref;

  final ChatStateNotifier chatStateNotifier;
  final LogStateNotifier logStateNotifier;

  Future<void> sendMessage(String message) async {
    final chatSession = await ref.read(chatSessionProvider.future);

    chatStateNotifier.addUserMessage(message);
    logStateNotifier.logUserText(message);
    final llmMessage = chatStateNotifier.createLlmMessage();
    try {
      final response = await chatSession.sendMessage(Content.text(message));

      final responseText = response.text;
      if (responseText != null) {
        logStateNotifier.logLlmText(responseText);
        chatStateNotifier.appendToMessage(llmMessage.id, responseText);
      }
    } catch (e, st) {
      logStateNotifier.logError(e, st: st);
      chatStateNotifier.appendToMessage(
        llmMessage.id,
        "\nI'm sorry, I encountered an error processing your request. "
        "Please try again.",
      );
    } finally {
      chatStateNotifier.finalizeMessage(llmMessage.id);
    }
  }
}

@riverpod
GeminiChatService geminiChatService(Ref ref) {
  final chatStateNotifier = ChatStateNotifier();
  final logStateNotifier = LogStateNotifier();
  return GeminiChatService(ref, chatStateNotifier, logStateNotifier);
}
