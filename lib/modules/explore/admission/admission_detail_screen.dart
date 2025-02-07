import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button_2.dart';
import "package:linkschool/modules/common/text_styles.dart";
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SchoolProfileScreen extends StatelessWidget {
  const SchoolProfileScreen({super.key});

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
            Image(
                image:
                    AssetImage('assets/images/explore-images/school-view.png'),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300),
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
              padding: const EdgeInsets.only(top: 310),
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
  const SchoolHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image(
          image: AssetImage('assets/images/explore-images/ls-logo.png'),
          width: 50,
          height: 50,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daughters Of Divine Love Juniorate',
                style:AppTextStyles.normal500(fontSize: 18, color:AppColors.aboutTitle),
              ),
              const SizedBox(height: 4),
              Text(
                '10 Ugwunwani St, Abakpa, Abakpa Nike 400103, Enugu',
               style: AppTextStyles.normal400(fontSize: 16, color: AppColors.detailsText),
              ),
              const SizedBox(height: 4),
              const Text(
                'Motto: Peace and Love and Integrity',
               style:AppTextStyles.normal2Light,
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
      height: 150,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
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
  const GallerySection({super.key});

  Widget _buildGalleryCategory(String title, List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.all(16),
          child: Text(
            title,
            style: AppTextStyles.normal600(fontSize: 16, color: AppColors.detailsText),
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
                margin: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
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
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg',
      'assets/images/explore-images/schools-in-Nigeria.jpg'
    ];

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Gallery'),
              Tab(text: 'Testimonials'),
              Tab(text: 'Other Info'),
            ],
            indicatorColor: AppColors.text2Light,
         labelColor:AppColors.text2Light, 
          ),
          SizedBox(
            height: 500,
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGalleryCategory(
                          'Buildings and facilities', dummyImages),
                      _buildGalleryCategory('Administrators', dummyImages),
                      _buildGalleryCategory(
                          'School activities and events', dummyImages),
                      _buildGalleryCategory('Alumni', dummyImages),
                      SizedBox(
                        height: 50,
                      ),
                      CustomOutlineButton(
                        onPressed: () {},
                        text: 'Get a Form: ₦10,000.00',
                        borderColor: AppColors.bgBorder,
                        textColor: AppColors.bgBorder,
                        width: 400,
                      )
                    ],
                  ),
                ),



                // Content for the "Testimonials" tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What people say about us',
                          style: AppTextStyles.normal400(
                              fontSize: 16, color: AppColors.aboutTitle),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        _TestimonyCard(
                          image:
                              'assets/images/explore-images/schools-in-Nigeria.jpg',
                          name: 'John Doe',
                          role: '(Parent)',
                          testimoney:
                              'DDLJ helped shape my child into the smart and excellent child that she is today. She always stands out!',
                        ),
                        _TestimonyCard(
                          image:
                              'assets/images/explore-images/schools-in-Nigeria.jpg',
                          name: 'Mrs Jane Doe',
                          role: '(Parent)',
                          testimoney:
                              'DDLJ helped shape my child into the smart and excellent child that she is today. She always stands out!',
                        ),
                        _TestimonyCard(
                          image:
                              'assets/images/explore-images/schools-in-Nigeria.jpg',
                          name: 'Mrs Jane Doe',
                          role: '(Parent)',
                          testimoney:
                              'DDLJ helped shape my child into the smart and excellent child that she is today. She always stands out!',
                        ),
                        _TestimonyCard(
                          image:
                              'assets/images/explore-images/schools-in-Nigeria.jpg',
                          name: 'John Doe',
                          role: '(Parent)',
                          testimoney:
                              'The years I spent as a juniorate student were some of the best years of my life',
                        )
                      ],
                    ),
                  ),
                ),
                // Content for the "Other Info" tab
              Column(
                children: [
                  MoreInfor(),
                ],
              )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// action_buttons.dart
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

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
              backgroundColor: AppColors.aboutTitle,
            ),
            child: Text('Get a Form: ₦10,000.00',
                style: AppTextStyles.normal500(
                  fontSize: 16,
                  color: AppColors.text6Light,
                )),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {},
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(AppColors.detailsbuttonbg),
              ),
              icon: const Icon(Icons.call_sharp,size: 18,color: AppColors.detailsbutton),
              label:  Text('Get contact info', style: AppTextStyles.normal400(fontSize: 16, color: AppColors.detailsbutton)),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message,size: 18,color: AppColors.detailsbutton),
              label:  Text('Send a message',style: AppTextStyles.normal400(fontSize: 16, color: AppColors.detailsbutton)),
            ),
          ],
        ),
      ],
    );
  }
}

// school_type_section.dart
class SchoolTypeSection extends StatelessWidget {
  const SchoolTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School type',
            style: AppTextStyles.normal600(fontSize: 16, color: AppColors.aboutTitle),
          ),
          SizedBox(height: 8),
          Text('Boarding Only (All girls)',style: AppTextStyles.normal400(fontSize: 16, color: AppColors.detailsText),),
        ],
      ),
    );
  }
}




// about_section.dart
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: AppTextStyles.normal500(
                fontSize: 16, color: AppColors.aboutTitle),
          ),
          SizedBox(height: 8),
          Text(
            'The father founder was rector of a junior seminary, a male juniorate before he was made a bishop. It was a concept he was converted to with and he knows the value of the saying, \'catch them young\'. He was aware of what could be got from the juniorate and believed that after the training, if one did not succeed in the being a religious/clergy, the person would at least be a good citizen.',
            style: AppTextStyles.normal400(fontSize: 16, color:AppColors.text4Light),
          ),
        ],
      ),
    );
  }
}


// testimony Section

class _TestimonyCard extends StatelessWidget {
  final String image;
  final String name;
  final String role;
  final String testimoney;
  final double rating;

  const _TestimonyCard(
      {super.key,
      required this.image,
      required this.name,
      required this.role,
      required this.testimoney,
      this.rating = 4.5});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(
            image: AssetImage(image),
            height: 50,
            width: 50,
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTextStyles.normal600(
                            fontSize: 16, color: AppColors.tesimonyName)),
                    Text((role),style: AppTextStyles.normal400(
                            fontSize: 16, color: AppColors.tesimonyName))
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  testimoney,
                  style:AppTextStyles.normal400(
                            fontSize: 16, color: AppColors.tesimonyName) ,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                RatingBar.builder(
                  itemBuilder: (context, index) {
                    return Icon(Icons.star, color: Colors.amber);
                  },
                  allowHalfRating: true,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 16,
                  initialRating: rating,
                  ignoreGestures: true,
                  onRatingUpdate: (rating) {},
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
// moreInfor tab
class MoreInfor extends StatelessWidget {
  const MoreInfor({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(16.0),
    child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            _schoolMotto(),
            SizedBox(height: 20,),
            _information()
      ],
    ),);
  }
}

Widget _schoolMotto (){
  return Row(
    children:[
      Text('School motto:',style:AppTextStyles.normal400(fontSize: 16, color: AppColors.aboutTitle),),
      Text('Faith and Love',style:AppTextStyles.normal400(fontSize: 16, color: AppColors.detailsText)),
    ]
  );
}

Widget _information(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('For more information and inquiries',style:AppTextStyles.normal400(fontSize: 16, color:AppColors.aboutTitle)),
      SizedBox(height: 10,),
      Row(children: [
        Icon(Icons.phone_in_talk),
        SizedBox(width: 5,),
        Text('07030804137, 08124848923',style:AppTextStyles.normal400(fontSize: 16, color:AppColors.inforText)),
      ],),
      Row(children: [
        Icon(Icons.email),
         SizedBox(width: 5,),
        Text('azuhchiamaka2018@gmail.com',style:AppTextStyles.normal400(fontSize: 16, color:AppColors.inforText)),
      ],)
    ],
  );
}
