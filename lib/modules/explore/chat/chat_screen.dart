import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_bubble.dart';
import 'services/deepseek_service.dart';


class Message {
  final String content;
  final bool isUser;

  Message({required this.content, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    
    setState(() {
      messages.add(Message(content: message, isUser: true));
      _controller.clear();
      _isLoading = true;
    });
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    
    try {
      final deepSeekService = Provider.of<DeepSeekService>(context, listen: false);
      final response = await deepSeekService.sendMessage(message);
      
      setState(() {
        messages.add(Message(content: response, isUser: false));
        _isLoading = false;
      });
      
      // Scroll to bottom after receiving response
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      print('Error sending message: $e'); // Debug print
      setState(() {
        messages.add(Message(
          content: "Sorry, I couldn't process your request. Please try again.",
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Chat'),
      //   elevation: 0,
      // ), far
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ChatBubble(
                    message: message.content,
                    isUser: message.isUser,
                  );
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }
}

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
  
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Message> messages = [];
//   bool _isInputCentered = true;
//   bool _isLoading = false;

//   void _sendMessage() async {
//     final message = _controller.text.trim();
//     if (message.isEmpty) return;
    
//     setState(() {
//       messages.add(Message(content: message, isUser: true));
//       _controller.clear();
//       _isInputCentered = false;
//       _isLoading = true;
//     });
    
//     try {
//       final deepSeekService = Provider.of<DeepSeekService>(context, listen: false);
//       final response = await deepSeekService.sendMessage(message);
      
//       setState(() {
//         messages.add(Message(content: response, isUser: false));
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         messages.add(Message(
//           content: "Sorry, I couldn't process your request. Please try again.",
//           isUser: false,
//         ));
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildInputField() {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(24),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//               ),
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.blue,
//             ),
//             child: IconButton(
//               icon: _isLoading
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Icon(Icons.send, color: Colors.white),
//               onPressed: _isLoading ? null : _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _isInputCentered && messages.isEmpty
//           ? Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: _buildInputField(),
//               ),
//             )
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.only(top: 16, bottom: 8),
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final message = messages[index];
//                       return ChatBubble(
//                         message: message.content,
//                         isUser: message.isUser,
//                       );
//                     },
//                   ),
//                 ),
//                 _buildInputField(),
//               ],
//             ),
//     );
//   }
// }