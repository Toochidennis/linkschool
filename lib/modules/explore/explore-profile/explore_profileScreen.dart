import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required double height, required Color color});

  @override
  Widget build(BuildContext context) {
    return Container(
      child:Kamso() ,
    );
  }
}









class Kamso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.3), // Blurry blue at top-left
                  Colors.white.withOpacity(0.0), // Fading to white
                  Colors.blue.withOpacity(0.6), // Blurry blue at top-right
                  Colors.white, // White background
                ],
                stops: [0.0, 0.3, 0.7, 1.0], 
              ),
            ),
            child: Center(
              child: Text(
                'Blurry Blue Gradient',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    
  }
}







// class ProfileSettingsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Account'),
//       ),
//       body: ListView(
//         children: <Widget>[
//           Center(
//             child: UserAccountsDrawerHeader(
//               accountName: Text('Chiramaka Winifred'),
//               accountEmail: Text('azuhchiramaka2018@gmail.com'),
//               currentAccountPicture: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Icon(
//                   Icons.person,
//                   size: 40,
//                 ),
//               ),
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.edit),
//             title: Text('Edit profile information'),
//             onTap: () {
//               // Navigate to edit profile page
//             },
//           ),
//           Divider(),
//           ListTile(
//             leading: Icon(Icons.color_lens),
//             title: Text('Theme'),
//             subtitle: Text('Light'),
//             onTap: () {
//               // Change theme
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.remove_circle_outline),
//             title: Text('Remove Ads'),
//             onTap: () {
//               // Remove ads
//             },
//           ),
//           Divider(),
//           ListTile(
//             leading: Icon(Icons.description),
//             title: Text('Terms & Conditions'),
//             onTap: () {
//               // Navigate to terms & conditions
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.help),
//             title: Text('Help and support'),
//             onTap: () {
//               // Navigate to help and support
//             },
//           ),
//           Divider(),
//           ListTile(
//             leading: Icon(Icons.exit_to_app),
//             title: Text('Logout'),
//             onTap: () {
//               // Perform logout
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }