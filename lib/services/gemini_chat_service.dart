import 'dart:async';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/gemini.dart';
import 'gemini_tools.dart';

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

  // Future<void> sendMessage(String message) async {
  //   final chatSession = await ref.read(chatSessionProvider.future);

  //   chatStateNotifier.addUserMessage(message);
  //   logStateNotifier.logUserText(message);
  //   final llmMessage = chatStateNotifier.createLlmMessage();
  //   try {
  //     final response = await chatSession.sendMessage(Content.text(message));

  //     final responseText = response.text;
  //     if (responseText != null) {
  //       logStateNotifier.logLlmText(responseText);
  //       chatStateNotifier.appendToMessage(llmMessage.id, responseText);
  //     }
  //   } catch (e, st) {
  //     logStateNotifier.logError(e, st: st);
  //     chatStateNotifier.appendToMessage(
  //       llmMessage.id,
  //       "\nI'm sorry, I encountered an error processing your request. "
  //       "Please try again.",
  //     );
  //   } finally {
  //     chatStateNotifier.finalizeMessage(llmMessage.id);
  //   }
  // }
  Future<void> sendMessage(String message, Function(String) onResponse) async {
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
        onResponse(responseText); // Kirim balasan ke UI
      }

      if (response.functionCalls.isNotEmpty) {
        final geminiTools = ref.read(geminiToolsProvider);

        final List<FunctionResponse> functionResponses = [];
        for (final functionCall in response.functionCalls) {
          final result = await geminiTools.handleFunctionCall(
            functionCall.name,
            functionCall.args,
          );
          functionResponses.add(FunctionResponse(functionCall.name, result));
        }

        final functionResultResponse = await chatSession.sendMessage(
          Content.functionResponses(functionResponses),
        );

        final responseText = functionResultResponse.text;
        // if (responseText != null) {
        //   logStateNotifier.logLlmText(responseText);
        //   chatStateNotifier.appendToMessage(llmMessage.id, responseText);
        // }
        if (responseText != null) {
          logStateNotifier.logLlmText(responseText);
          chatStateNotifier.appendToMessage(llmMessage.id, responseText);
          onResponse(responseText); // Kirim balasan ke UI
        }
      }
    } catch (e, st) {
      logStateNotifier.logError(e, st: st);
      final errorMessage =
          "\nI'm sorry, I encountered an error processing your request. Please try again.";
      chatStateNotifier.appendToMessage(llmMessage.id, errorMessage);
      onResponse(errorMessage); // Kirim pesan error ke UI
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
