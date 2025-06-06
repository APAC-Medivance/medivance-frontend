import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hajjhealth/providers/gemini.dart';
import 'package:hajjhealth/services/gemini_chat_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MediBotScreen extends StatelessWidget {
  const MediBotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
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

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

    // Dapatkan ID user yang sedang login
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Jika user belum login, gunakan nama default
      setState(() {
        _userName = 'Guest';
      });
      return;
    }

    final userId = currentUser.uid; // ID user saat ini
    final userRef = database.ref('user_profiles/$userId/name');

    userRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          _userName = data.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(geminiModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: model.when(
          data:
              (data) => Column(
                children: [
                  // App bar
                  _buildAppBar(context),
                  Container(
                    height: 1,
                    color: Colors.blue.withOpacity(0.3),
                    width: double.infinity,
                  ),
                  // Chat messages
                  // Expanded(
                  //   child: ListView.builder(
                  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //     itemCount: _messages.length,
                  //     itemBuilder: (context, index) {
                  //       final message = _messages[index];
                  //       return _buildMessageBubble(context, message);
                  //     },
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, // Tambahkan ini
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(context, message);
                      },
                    ),
                  ),
                  // Input area
                  _buildInputArea(context),
                ],
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              Navigator.of(context, rootNavigator: true).pushNamed("/home");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.medical_services, color: Colors.blue, size: 16),
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
                  padding: EdgeInsets.only(left: 4.0, bottom: 2.0),
                  child: Text(
                    'Medibot',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: message.isUser ? Colors.blue[500] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              if (message.isUser)
                // const Padding(
                Padding(
                  padding: EdgeInsets.only(right: 4.0, top: 2.0),
                  child: Text(
                    // 'User',
                    _userName,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
            ],
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blue,
              backgroundImage: const AssetImage('assets/user_avatar.png'),
              onBackgroundImageError: (exception, stackTrace) {},
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
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
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),

                  // onPressed: () {
                  //   final text = _controller.text.trim();
                  //   if (text.isNotEmpty) {
                  //     setState(() {
                  //       _messages.add(ChatMessage(text: text, isUser: true));
                  //       _controller.clear();
                  //     });
                  //     ref.read(geminiChatServiceProvider).sendMessage(text, (
                  //       response,
                  //     ) {
                  //       setState(() {
                  //         _messages.add(
                  //           ChatMessage(text: response, isUser: false),
                  //         );
                  //       });
                  //     });
                  //   }
                  // },
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _messages.add(ChatMessage(text: text, isUser: true));
                        _controller.clear();
                      });

                      setState(() {
                        _messages.add(
                          ChatMessage(text: 'Loading...', isUser: false),
                        );
                      });

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      ref.read(geminiChatServiceProvider).sendMessage(text, (
                        response,
                      ) {
                        setState(() {
                          _messages.removeLast();
                          _messages.add(
                            ChatMessage(text: response, isUser: false),
                          );
                        });

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
