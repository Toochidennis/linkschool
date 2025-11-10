import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/home/admission_model.dart';
import 'package:linkschool/modules/providers/explore/home/admission_provider.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/admission/admission_detail_screen.dart';


class ExploreAdmission extends StatefulWidget {
  const ExploreAdmission({super.key, required this.height});

  final double height;

  @override
  State<ExploreAdmission> createState() => _ExploreAdmissionState();
}

class _ExploreAdmissionState extends State<ExploreAdmission> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdmissionProvider>().loadAdmissions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<School> _filterSchools(List<School> schools) {
    if (_searchQuery.isEmpty) {
      return schools;
    }
    return schools.where((school) {
      return school.schoolName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             school.location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search schools...',
                hintStyle: AppTextStyles.normal400(
                  fontSize: 14,
                  color: AppColors.text5Light,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.text2Light,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.textField(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.textFieldBorder(context),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.textFieldBorder(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.text2Light,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // TabBar
                  TabBar(
                    indicatorColor: AppColors.text2Light,
                    labelColor: AppColors.text2Light,
                    tabs: const [
                      Tab(text: 'Top'),
                      Tab(text: 'Near me'),
                      Tab(text: 'Recommended'),
                    ],
                  ),
                  // TabBarView
                  Expanded(
                    child: Consumer<AdmissionProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (provider.errorMessage != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(provider.errorMessage!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => provider.loadAdmissions(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (provider.admissionData == null) {
                          return const Center(
                            child: Text('No data available'),
                          );
                        }

                        return TabBarView(
                          children: [
                            // Tab 1: Top
                            _buildTopTab(_filterSchools(provider.admissionData!.data.top)),
                            // Tab 2: Near me
                            _buildNearMeTab(_filterSchools(provider.admissionData!.data.nearMe)),
                            // Tab 3: Recommended
                            _buildRecommendedTab(_filterSchools(provider.admissionData!.data.recommend)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildTopTab(List<School> schools) {
  if (schools.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.text5Light,
          ),
          const SizedBox(height: 16),
          Text(
            'No schools found',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: AppColors.text5Light,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: AppTextStyles.normal400(
              fontSize: 14,
              color: AppColors.text5Light,
            ),
          ),
        ],
      ),
    );
  }

  return ListView(
    children: [
      _TextIconRow(
        text: 'Top rated Schools',
        icon: Icons.arrow_forward,
      ),
      const SizedBox(height: 8),
      CarouselSlider(
        items: schools.take(5).map((school) {
          return _SchoolCard(
            context: context,
            school: school,
          );
        }).toList(),
        options: CarouselOptions(
          height: 220.0,
          viewportFraction: 0.8,
          padEnds: false,
          autoPlay: true,
          enableInfiniteScroll: schools.length > 1,
          scrollDirection: Axis.horizontal,
        ),
      ),
      const SizedBox(height: 16),
      _TextIconRow(
        text: 'You might also like',
        icon: Icons.arrow_forward,
      ),
      const SizedBox(height: 8),
      CarouselSlider(
        items: schools.map((school) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchoolProfileScreen(school: school),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _SearchItems(school: school, context: context),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          viewportFraction: 0.9,
          enableInfiniteScroll: false,
          padEnds: true,
          autoPlay: false,
          scrollDirection: Axis.horizontal,
        ),
      ),
      const SizedBox(height: 16),
      _TextIconRow(
        text: 'Based on your recent searches',
        icon: Icons.arrow_forward,
      ),
      const SizedBox(height: 8),
      ...schools.take(3).map((school) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _BasedOnSearches(context: context, school: school),
      )),
    ],
  );
}

  Widget _buildNearMeTab(List<School> schools) {
    if (schools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.text5Light,
            ),
            const SizedBox(height: 16),
            Text(
              'No schools found',
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: AppColors.text5Light,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: AppColors.text5Light,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schools.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchoolProfileScreen(school: schools[index]),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: _SearchItems(school: schools[index], context: context),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Search using Google Map',
            style: AppTextStyles.normal400(
              fontSize: 16,
              color: AppColors.admissionTitle,
            ),
          ),
        ),
        const MapSection(),
      ],
    );
  }

  Widget _buildRecommendedTab(List<School> schools) {
    if (schools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.text5Light,
            ),
            const SizedBox(height: 16),
            Text(
              'No schools found',
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: AppColors.text5Light,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: AppTextStyles.normal400(
                fontSize: 14,
                color: AppColors.text5Light,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schools.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolProfileScreen(school: schools[index]),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _BasedOnSearches(context: context, school: schools[index]),
          ),
        );
      },
    );
  }
}

// Updated School Card with API data
Widget _SchoolCard({
  required BuildContext context,
  required School school,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolProfileScreen(school: school),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              school.banner,
              fit: BoxFit.cover,
              height: 123,
              width: 244,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 123,
                  width: 244,
                  color: Colors.grey[300],
                  child: const Icon(Icons.school, size: 50),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          _TopSchoolDescription(school: school),
        ],
      ),
    ),
  );
}

Widget _TopSchoolDescription({required School school}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            school.logo,
            fit: BoxFit.cover,
            height: 48,
            width: 48,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 48,
                width: 48,
                color: Colors.grey[300],
                child: const Icon(Icons.school),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.schoolName,
                style: AppTextStyles.normal600(
                  fontSize: 16,
                  color: AppColors.text3Light,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Form for sale at ₦${school.admissionPrice.toStringAsFixed(2)}',
                style: AppTextStyles.normal400(
                  fontSize: 16,
                  color: AppColors.schoolform,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                    'Admissions:',
                    style: AppTextStyles.normal400(
                      fontSize: 14,
                      color: AppColors.text3Light,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    school.isAdmission ? 'open' : 'closed',
                    style: AppTextStyles.normal400(
                      fontSize: 14,
                      color: school.isAdmission 
                        ? AppColors.admissionopen 
                        : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
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
    ),
  );
}

Widget _BasedOnSearches({
  required BuildContext context,
  required School school,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolProfileScreen(school: school),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 328,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                school.banner,
                fit: BoxFit.cover,
                height: 123,
                width: 328,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 123,
                    width: 328,
                    color: Colors.grey[300],
                    child: const Icon(Icons.school, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            _TopSchoolDescription(school: school),
          ],
        ),
      ),
    ),
  );
}

Widget _SearchItems({required School school, required BuildContext context}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchoolProfileScreen(school: school),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              school.logo,
              fit: BoxFit.cover,
              height: 50,
              width: 50,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 50,
                  width: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.school),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.schoolName,
                  style: AppTextStyles.normal700(
                    fontSize: 16,
                    color: AppColors.schooltext,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Form for sale at ₦${school.admissionPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.normal700(
                    fontSize: 16,
                    color: AppColors.schoolform,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        school.location,
                        style: AppTextStyles.normal700(
                          fontSize: 16,
                          color: AppColors.schooltext,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      school.isAdmission ? 'open' : 'closed',
                      style: TextStyle(
                        fontSize: 14,
                        color: school.isAdmission ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _TextIconRow({required String text, required IconData icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.normal400(
              fontSize: 18,
              color: AppColors.admissionTitle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(icon),
      ],
    ),
  );
}

// MapSection widget (keep as is from your original code)
class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('Map Placeholder')),
    );
  }
}