import 'package:flutter/material.dart';
import 'package:overlay/screens/profile_page.dart';

import 'home.dart';
import '../services/prompts.dart';

class ChatBotScreen extends StatefulWidget {
  Map<String, dynamic> user;
  final int currentIndex; // To keep track of active tab
  ChatBotScreen({super.key, required this.user, required this.currentIndex});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages.add(Message(
        text: "Hi, I am the EatWise Guide. How may I assist you?",
        isMe: false));
  }

  void onSendMessage() async {
    Message message = Message(text: _textEditingController.text, isMe: true);

    if (message.text.isEmpty) return;

    _textEditingController.clear();

    setState(() {
      _messages.insert(0, message);
    });

    String response = await chatResponse(message.text);
    Message bot = Message(text: response, isMe: false);

    setState(() {
      _messages.insert(0, bot);
    });
  }

  Widget _buildMessage(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              message.isMe ? 'You' : 'EatWise Guide',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: message.isMe ? Colors.teal[800] : Colors.teal[400],
                fontSize: 12,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 280,
            ),
            decoration: BoxDecoration(
              color: message.isMe
                  ? const Color(0xFF004d40)
                  : const Color(0xFF86b649),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: message.isMe ? Colors.white : Colors.white,
                fontFamily: 'Roboto', // Consistent font style
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E7),
      appBar: AppBar(
        title: const Text(
          'EatWise Guide',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto', // Modern font
          ),
        ),
        backgroundColor: const Color(0xFF004d40),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMessage(_messages[index]);
              },
              physics: const BouncingScrollPhysics(), // Smooth scrolling effect
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: _buildTextComposer(), // Custom text input field
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        backgroundColor: const Color(0xFF004d40),
        unselectedItemColor: Colors.grey[600],
        selectedItemColor: Colors.white,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 2.0),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            onPressed: onSendMessage,
            icon: const Icon(
              Icons.send,
              color: Color(0xFF004d40),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              user: widget.user,
              currentIndex: 0,
            ),
          ),
        );
        break;
      case 1:
        // Stay on current page (ChatBotScreen)
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              user: widget.user,
              currentIndex: 2,
            ),
          ),
        );
        break;
    }
  }
}

class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}
