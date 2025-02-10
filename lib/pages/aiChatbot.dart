import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:finwise/services/expense_service.dart';

class AIChatBot extends StatefulWidget {
  const AIChatBot({super.key});

  @override
  State<AIChatBot> createState() => _AIChatBotState();
}

class _AIChatBotState extends State<AIChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  List<Map<String, dynamic>> chatSessions = [];
  String? currentSessionId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startNewChat();
    _loadChatSessions(); // Fetch all sessions when chatbot opens
  }

  //  Fetch all chat sessions from backend
  void _loadChatSessions() async {
    List<Map<String, dynamic>> sessions = await ExpenseService.fetchChatSessions();
    
    setState(() {
      chatSessions = sessions;
    });

  }

  // Fetch chat history by session ID
  void _loadChatHistoryBySession(String sessionId) async {
    List<Map<String, dynamic>> history = await ExpenseService.fetchChatHistoryBySession(sessionId);

    setState(() {
      currentSessionId = sessionId;
      messages = history.expand((chat) => [
        {"sender": "user", "message": (chat["query"] ?? "").toString()},
        {"sender": "ai", "message": (chat["response"] ?? "").toString()},
      ]).toList();
    });

    _scrollToBottom();
  }

  // Start a new chat session
  void _startNewChat() {
    setState(() {
      currentSessionId = null;
      messages.clear();
    });
  }

  // Send a user message and fetch AI response
  void _sendMessage() async {
  if (_messageController.text.isEmpty) return;

  String userMessage = _messageController.text.trim();
  setState(() {
    messages.add({"sender": "user", "message": userMessage});
    _messageController.clear();
    isLoading = true;
  });

  _scrollToBottom();

  // Fetch AI response
  String aiResponse = await ExpenseService.sendAIQuery(userMessage);

  setState(() {
    messages.add({"sender": "ai", "message": aiResponse});
    isLoading = false;
  });

  _scrollToBottom();

  // Ensure session exists or create a new one
  if (currentSessionId == null) {
    currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await ExpenseService.saveChat(currentSessionId!, userMessage, aiResponse);
    _loadChatSessions(); // Only refresh session list when a new session is created
  } else {
    await ExpenseService.saveChat(currentSessionId!, userMessage, aiResponse);
  }
}


  // 📌 Scroll to bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Drawer to show chat history
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text(
                "Chat History",
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
            ),
            Expanded(
              child: chatSessions.isEmpty
                  ? const Center(child: Text("No chat sessions available."))
                  : ListView.builder(
                      itemCount: chatSessions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(chatSessions[index]["sessionName"] ?? "Chat ${index + 1}"),
                          onTap: () {
                            _loadChatHistoryBySession(chatSessions[index]["_id"]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text("AI Expense Advisor"),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _startNewChat, // ✅ Start new chat button
          ),
        ],
      ),

      // 📌 Chat Messages Display
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isUser
                        ? Text(
                            msg["message"]!,
                            style: const TextStyle(fontSize: 16),
                          )
                        : MarkdownBody(
                            data: msg["message"]!,
                            styleSheet: MarkdownStyleSheet(
                              h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              p: const TextStyle(fontSize: 16),
                              strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              listBullet: const TextStyle(fontSize: 16),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // 📌 Input Field + Send Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ask about your spending...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),

      // 📌 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/expenses');
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Expense"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "ChatBot"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
