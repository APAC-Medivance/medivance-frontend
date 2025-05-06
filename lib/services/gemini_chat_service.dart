import 'dart:async';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/gemini.dart';

part 'gemini_chat_service.g.dart';

class GeminiChatService {
  GeminiChatService(this.ref);
  final Ref ref;

  Future<void> sendMessage(String message) async {
    final chatSession = await ref.read(chatSessionProvider.future);
    final chatStateNotifier = ref.read(chatStateNotifierProvider.notifier);
    final logStateNotifier = ref.read(logStateNotifierProvider.notifier);

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
GeminiChatService geminiChatService(Ref ref) => GeminiChatService(ref);
