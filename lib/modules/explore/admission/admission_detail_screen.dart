import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/buttons/custom_outline_button..dart';
import "package:linkschool/modules/common/text_styles.dart";
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:linkschool/modules/model/explore/home/admission_model.dart';


class SchoolProfileScreen extends StatelessWidget {
  final School school;

  const SchoolProfileScreen({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Banner Image
            Image.network(
              school.banner,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.school, size: 100),
                );
              },
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
                child: SchoolHeader(school: school),
              ),
            ),
            // Rest of the content
            Padding(
              padding: const EdgeInsets.only(top: 310),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MapSection(school: school),
                  ActionButtons(school: school),
                  SchoolTypeSection(school: school),
                  AboutSection(school: school),
                  GallerySection(school: school),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchoolHeader extends StatelessWidget {
  final School school;

  const SchoolHeader({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            school.logo,
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.school),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.schoolName,
                style: AppTextStyles.normal500(
                  fontSize: 18,
                  color: AppColors.aboutTitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                school.address,
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: AppColors.detailsText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Motto: ${school.motto}',
                style: AppTextStyles.normal2Light,
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    school.rating.toString(),
                    style: AppTextStyles.normal400(
                      fontSize: 14,
                      color: AppColors.text3Light,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MapSection extends StatelessWidget {
  final School school;

  const MapSection({super.key, required this.school});

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 40),
                      Text(
                        'Lat: ${school.latitude.toStringAsFixed(4)}, '
                        'Long: ${school.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
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

class GallerySection extends StatelessWidget {
  final School school;

  const GallerySection({super.key, required this.school});

  Widget _buildGalleryCategory(String title, List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: AppTextStyles.normal600(
              fontSize: 16,
              color: AppColors.detailsText,
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
                margin: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    width: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      );
                    },
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
            labelColor: AppColors.text2Light,
          ),
          SizedBox(
            height: 500,
            child: TabBarView(
              children: [
                // Gallery Tab
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGalleryCategory('School Gallery', school.gallery),
                      const SizedBox(height: 50),
                      CustomOutlineButton(
                        onPressed: () {},
                        text: 'Get a Form: ₦${school.admissionPrice.toStringAsFixed(2)}',
                        borderColor: AppColors.bgBorder,
                        textColor: AppColors.bgBorder,
                        width: 400,
                      ),
                    ],
                  ),
                ),

                // Testimonials Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What people say about us',
                          style: AppTextStyles.normal400(
                            fontSize: 16,
                            color: AppColors.aboutTitle,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (school.testimonials.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No testimonials available'),
                            ),
                          )
                        else
                          ...school.testimonials.map((testimonial) {
                            return _TestimonyCard(
                              testimonial: testimonial,
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                // Other Info Tab
                MoreInfo(school: school),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final School school;

  const ActionButtons({super.key, required this.school});

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
            child: Text(
              'Get a Form: ₦${school.admissionPrice.toStringAsFixed(2)}',
              style: AppTextStyles.normal500(
                fontSize: 16,
                color: AppColors.text6Light,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {
                // Show contact dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Contact Information'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone),
                            const SizedBox(width: 8),
                            Text(school.contact.phone),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email),
                            const SizedBox(width: 8),
                            Expanded(child: Text(school.contact.email)),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(AppColors.detailsbuttonbg),
              ),
              icon: const Icon(
                Icons.call_sharp,
                size: 18,
                color: AppColors.detailsbutton,
              ),
              label: Text(
                'Get contact info',
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: AppColors.detailsbutton,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.message,
                size: 18,
                color: AppColors.detailsbutton,
              ),
              label: Text(
                'Send a message',
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: AppColors.detailsbutton,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SchoolTypeSection extends StatelessWidget {
  final School school;

  const SchoolTypeSection({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School type',
            style: AppTextStyles.normal600(
              fontSize: 16,
              color: AppColors.aboutTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            school.schoolType,
            style: AppTextStyles.normal400(
              fontSize: 16,
              color: AppColors.detailsText,
            ),
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  final School school;

  const AboutSection({super.key, required this.school});

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
              fontSize: 16,
              color: AppColors.aboutTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            school.about,
            style: AppTextStyles.normal400(
              fontSize: 16,
              color: AppColors.text4Light,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonyCard extends StatelessWidget {
  final Testimonial testimonial;

  const _TestimonyCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                testimonial.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testimonial.name,
                  style: AppTextStyles.normal600(
                    fontSize: 16,
                    color: AppColors.tesimonyName,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  testimonial.content,
                  style: AppTextStyles.normal400(
                    fontSize: 16,
                    color: AppColors.tesimonyName,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                const SizedBox(height: 4),
                RatingBar.builder(
                  itemBuilder: (context, index) {
                    return const Icon(Icons.star, color: Colors.amber);
                  },
                  allowHalfRating: true,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 16,
                  initialRating: testimonial.rating,
                  ignoreGestures: true,
                  onRatingUpdate: (rating) {},
                ),
                Text(
                  testimonial.date,
                  style: AppTextStyles.normal400(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MoreInfo extends StatelessWidget {
  final School school;

  const MoreInfo({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'School motto: ',
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: AppColors.aboutTitle,
                ),
              ),
              Expanded(
                child: Text(
                  school.motto,
                  style: AppTextStyles.normal400(
                    fontSize: 16,
                    color: AppColors.detailsText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'For more information and inquiries',
            style: AppTextStyles.normal400(
              fontSize: 16,
              color: AppColors.aboutTitle,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone_in_talk),
              const SizedBox(width: 5),
              Text(
                school.contact.phone,
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: AppColors.inforText,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.email),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  school.contact.email,
                  style: AppTextStyles.normal400(
                    fontSize: 16,
                    color: AppColors.inforText,
                  ),
                ),
              ),
            ],
          ),
          if (school.startDate != null && school.endDate != null) ...[
            const SizedBox(height: 10),
            Text(
              'Admission Period',
              style: AppTextStyles.normal400(
                fontSize: 16,
                color: AppColors.aboutTitle,
              ),
            ),
            Text(
              'From: ${school.startDate} to ${school.endDate}',
              style: AppTextStyles.normal400(
                fontSize: 16,
                color: AppColors.detailsText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}