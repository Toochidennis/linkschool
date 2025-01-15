import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg

class SchoolProfileScreen extends StatelessWidget {
  const SchoolProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Image (SVG)
            SvgPicture.asset(
              'assets/images/admission/admission_detail_img1.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            ),
            // Header Section
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const SchoolHeader(),
              ),
            ),
            // Rest of the content
            Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  // Map Section
                  MapSection(),
                  
                  // Action Buttons
                  ActionButtons(),
                  
                  // School Type Section
                  SchoolTypeSection(),
                  
                  // About Section
                  AboutSection(),
                  
                  // Gallery Section
                  GallerySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// school_header.dart
class SchoolHeader extends StatelessWidget {
  const SchoolHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // School Logo (SVG)
        SvgPicture.asset(
          'assets/images/admission/admission_detail_logo_img.svg',
          width: 60,
          height: 60,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Daughters Of Divine Love Juniorate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '10 Ugwunwani St, Abakpa, Abakpa Nike 400103, Enugu',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Motto: Peace and Love and Integrity',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// map_section.dart
class MapSection extends StatelessWidget {
  const MapSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: SvgPicture.asset(
                'assets/images/map_placeholder.svg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: const Text(
              'Get directions on Google map',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// gallery_section.dart
class GallerySection extends StatelessWidget {
  const GallerySection({Key? key}) : super(key: key);

  Widget _buildGalleryCategory(String title, List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SvgPicture.asset(
                    imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const dummyImages = [
      'assets/images/gallery_placeholder.svg',
      'assets/images/gallery_placeholder.svg',
      'assets/images/gallery_placeholder.svg',
    ];

    return Column(
      children: [
        DefaultTabController(
          length: 3,
          child: TabBar(
            tabs: const [
              Tab(text: 'Gallery'),
              Tab(text: 'Testimonials'),
              Tab(text: 'Other Info'),
            ],
            labelColor: Theme.of(context).primaryColor,
          ),
        ),
        _buildGalleryCategory('Buildings and facilities', dummyImages),
        _buildGalleryCategory('Administrators', dummyImages),
        _buildGalleryCategory('School activities and events', dummyImages),
        _buildGalleryCategory('Alumni', dummyImages),
      ],
    );
  }
}



// import 'package:flutter/material.dart';

// class SchoolProfileScreen extends StatelessWidget {
//   const SchoolProfileScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       extendBodyBehindAppBar: true,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             // Background Image
//             Image.network(
//               'https://via.placeholder.com/400x200',
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: 250,
//             ),
//             // Header Section
//             Positioned(
//               top: 200,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: const SchoolHeader(),
//               ),
//             ),
//             // Rest of the content
//             Padding(
//               padding: const EdgeInsets.only(top: 300),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: const [
//                   // Map Section
//                   MapSection(),
                  
//                   // Action Buttons
//                   ActionButtons(),
                  
//                   // School Type Section
//                   SchoolTypeSection(),
                  
//                   // About Section
//                   AboutSection(),
                  
//                   // Gallery Section
//                   GallerySection(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // school_header.dart
// class SchoolHeader extends StatelessWidget {
//   const SchoolHeader({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 30,
//           backgroundImage: NetworkImage(
//             'https://via.placeholder.com/60',
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               Text(
//                 'Daughters Of Divine Love Juniorate',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 '10 Ugwunwani St, Abakpa, Abakpa Nike 400103, Enugu',
//                 style: TextStyle(fontSize: 14),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'Motto: Peace and Love and Integrity',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // map_section.dart
// class MapSection extends StatelessWidget {
//   const MapSection({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//               child: Image.network(
//                 'https://via.placeholder.com/400x150',
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             width: double.infinity,
//             child: const Text(
//               'Get directions on Google map',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.blue,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// action_buttons.dart
class ActionButtons extends StatelessWidget {
  const ActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Get a Form: ₦10,000.00'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone),
              label: const Text('Get contact info'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message),
              label: const Text('Send a message'),
            ),
          ],
        ),
      ],
    );
  }
}

// gallery_section.dart
// class GallerySection extends StatelessWidget {
//   const GallerySection({Key? key}) : super(key: key);

//   Widget _buildGalleryCategory(String title, List<String> imageUrls) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 120,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: imageUrls.length,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemBuilder: (context, index) {
//               return Container(
//                 width: 160,
//                 margin: const EdgeInsets.only(right: 8),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     imageUrls[index],
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const dummyImages = [
//       'https://via.placeholder.com/160x120',
//       'https://via.placeholder.com/160x120',
//       'https://via.placeholder.com/160x120',
//     ];

//     return Column(
//       children: [
//         DefaultTabController(
//           length: 3,
//           child: TabBar(
//             tabs: const [
//               Tab(text: 'Gallery'),
//               Tab(text: 'Testimonials'),
//               Tab(text: 'Other Info'),
//             ],
//             labelColor: Theme.of(context).primaryColor,
//           ),
//         ),
//         _buildGalleryCategory('Buildings and facilities', dummyImages),
//         _buildGalleryCategory('Administrators', dummyImages),
//         _buildGalleryCategory('School activities and events', dummyImages),
//         _buildGalleryCategory('Alumni', dummyImages),
//       ],
//     );
//   }
// }

// school_type_section.dart
class SchoolTypeSection extends StatelessWidget {
  const SchoolTypeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'School type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Boarding Only (All girls)'),
        ],
      ),
    );
  }
}

// about_section.dart
class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The father founder was rector of a junior seminary, a male juniorate before he was made a bishop. It was a concept he was converted to with and he knows the value of the saying, \'catch them young\'. He was aware of what could be got from the juniorate and believed that after the training, if one did not succeed in the being a religious/clergy, the person would at least be a good citizen.',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}