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
  final ScrollController _scrollController = ScrollController(); // Scroll controller for automatic scrolling
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  // Function to send user query to backend AI
  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    String userMessage = _messageController.text.trim();
    setState(() {
      messages.add({"sender": "user", "message": userMessage});
      _messageController.clear();
      isLoading = true;
    });

    // Scroll to the bottom after sending the message
    _scrollToBottom();

    // Send request to backend
    String aiResponse = await ExpenseService.sendAIQuery(userMessage);

    setState(() {
      messages.add({"sender": "ai", "message": aiResponse});
      isLoading = false;
    });

    // Scroll to the bottom after receiving the response
    _scrollToBottom();
  }

  // Function to scroll to the bottom of the list
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
      appBar: AppBar(
        title: const Text("AI Expense Advisor"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Chat Messages Display
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
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
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
                              h1: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.8,
                              ),
                              p: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              listBullet: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                              ),
                              blockquote: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                height: 1.6,
                              ),
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

          // Input Field + Send Button
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

      // Bottom Navigation Bar
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
