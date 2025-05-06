import 'package:flutter/material.dart';
import 'package:hajjhealth/view/users/navbar_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class MediBotScreen extends StatelessWidget {
  const MediBotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Tambahkan ProviderScope di sini
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MediBot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'SF Pro Display',
        ),
        home: const ChatScreen(),
      ),
    );
  }
}

// Provider for managing chat messages
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      return ChatMessagesNotifier();
    });

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addUserMessage(String text) async {
    final id = DateTime.now().toIso8601String(); // Buat ID unik
    state = [...state, ChatMessage(id: id, text: text, isUser: true)];

    // Panggil model LLM untuk mendapatkan respons
    final botResponse = await getBotResponse(text);

    // Tambahkan respons bot ke state
    addBotResponse(botResponse);
  }

  Future<String> getBotResponse(String userInput) async {
    try {
      // Contoh pemanggilan model LLM (misalnya Firebase Vertex AI)
      final chatSession =
          await FirebaseVertexAI.instance
              .generativeModel(model: 'gemini-2.0-flash')
              .startChat();

      final response = await chatSession.sendMessage(Content.text(userInput));
      return response.text ?? "I'm sorry, I couldn't understand that.";
    } catch (e) {
      // Tangani error
      return "I'm sorry, I encountered an error.";
    }
  }

  void addBotResponse(String text) {
    final id = DateTime.now().toIso8601String(); // Buat ID unik
    state = [...state, ChatMessage(id: id, text: text, isUser: false)];
  }
}

class ChatScreen extends ConsumerWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatMessages = ref.watch(chatMessagesProvider);
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'assets/medibot_logo.png',
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.medical_services,
                                color: Colors.blue,
                                size: 24,
                              ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'MediBot',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed("/home");
                    },
                  ),
                ],
              ),
            ),

            Container(
              height: 1,
              color: Colors.blue.withOpacity(0.3),
              width: double.infinity,
            ),

            // Chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          message.isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.isUser) ...[
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.medical_services,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Column(
                          crossAxisAlignment:
                              message.isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            if (!message.isUser)
                              const Padding(
                                padding: EdgeInsets.only(
                                  left: 4.0,
                                  bottom: 2.0,
                                ),
                                child: Text(
                                  'Doctor Bot',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    message.isUser
                                        ? Colors.blue[500]
                                        : Colors.blue[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color:
                                      message.isUser
                                          ? Colors.white
                                          : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (message.isUser)
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0, top: 2.0),
                                child: Text(
                                  'User',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (message.isUser) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue,
                            backgroundImage: const AssetImage(
                              'assets/user_avatar.png',
                            ),
                            onBackgroundImageError: (exception, stackTrace) {},
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask anything',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: () {
                            final text = _controller.text.trim();
                            if (text.isNotEmpty) {
                              ref
                                  .read(chatMessagesProvider.notifier)
                                  .addUserMessage(text);
                              _controller.clear();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;

  ChatMessage({required this.id, required this.text, required this.isUser});
}
