import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/deepseek_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  void _sendMessage() async {
    final message = _controller.text;
    if (message.isEmpty) return;

    setState(() {
      messages.add('You: $message');
      _controller.clear();
    });

    final deepSeekService = Provider.of<DeepSeekService>(context, listen: false);
    final response = await deepSeekService.sendMessage(message);

    setState(() {
      messages.add('Chatbot: $response');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DeepSeek Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/constants.dart';

// class CartScreen extends StatefulWidget {
//   final double height;

//   const CartScreen({
//     super.key, 
//     required this.height,
//   });

//   @override
//   _CartScreenState createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   List<CartItem> cartItems = [
//     CartItem(
//       name: 'Programming Textbook',
//       price: 29.99,
//       quantity: 1,
//       image: 'assets/images/book1.png',
//     ),
//     CartItem(
//       name: 'Mathematics Workbook',
//       price: 19.99,
//       quantity: 2,
//       image: 'assets/images/book2.png',
//     ),
//   ];

//   double get totalPrice {
//     return cartItems.fold(0, (total, item) => total + (item.price * item.quantity));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: Constants.customScreenDec0ration(),
//         width: double.infinity,
//         height: double.infinity,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'My Cart',
//                   style: AppTextStyles.normal600(
//                     fontSize: 22, 
//                     color: AppColors.profileTitle
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: cartItems.length,
//                   itemBuilder: (context, index) {
//                     return CartItemWidget(
//                       item: cartItems[index],
//                       onQuantityChanged: (newQuantity) {
//                         setState(() {
//                           cartItems[index].quantity = newQuantity;
//                         });
//                       },
//                       onRemove: () {
//                         setState(() {
//                           cartItems.removeAt(index);
//                         });
//                       },
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Total',
//                       style: AppTextStyles.normal600(
//                         fontSize: 18, 
//                         color: AppColors.profileTitle
//                       ),
//                     ),
//                     Text(
//                       '\$${totalPrice.toStringAsFixed(2)}',
//                       style: AppTextStyles.normal600(
//                         fontSize: 18, 
//                         color: AppColors.profileTitle
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Implement checkout logic
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.barColor2,
//                       padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                     ),
//                     child: Text(
//                       'Checkout',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CartItem {
//   String name;
//   double price;
//   int quantity;
//   String image;

//   CartItem({
//     required this.name,
//     required this.price,
//     required this.quantity,
//     required this.image,
//   });
// }

// class CartItemWidget extends StatelessWidget {
//   final CartItem item;
//   final Function(int) onQuantityChanged;
//   final VoidCallback onRemove;

//   const CartItemWidget({
//     Key? key,
//     required this.item,
//     required this.onQuantityChanged,
//     required this.onRemove,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             Image.asset(
//               item.image,
//               width: 80,
//               height: 80,
//               fit: BoxFit.cover,
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.name,
//                     style: AppTextStyles.normal500(
//                       fontSize: 16, 
//                       color: AppColors.profileTitle
//                     ),
//                   ),
//                   Text(
//                     '\$${item.price.toStringAsFixed(2)}',
//                     style: AppTextStyles.normal400(
//                       fontSize: 14, 
//                       color: AppColors.profileSubTitle
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.remove),
//                   onPressed: () {
//                     if (item.quantity > 1) {
//                       onQuantityChanged(item.quantity - 1);
//                     }
//                   },
//                 ),
//                 Text('${item.quantity}'),
//                 IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () {
//                     onQuantityChanged(item.quantity + 1);
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete, color: Colors.red),
//                   onPressed: onRemove,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }