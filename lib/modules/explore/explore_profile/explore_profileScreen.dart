import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(
      {super.key, required double height, required Color color});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ProfileHomeScreen(),
    );
  }
}

class ProfileHomeScreen extends StatefulWidget {
  @override
  _ProfileHomeScreenState createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
  bool _isAdRemoved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.normal600(fontSize: 18.0, color: AppColors.eLearningBtnColor1,)
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.eLearningBtnColor1,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        // flexibleSpace: FlexibleSpaceBar(
        //   background: Stack(
        //     children: [
        //       Positioned.fill(
        //         child: Opacity(
        //           opacity: opacity,
        //           child: Image.asset(
        //             'assets/images/background.png',
        //             fit: BoxFit.cover,
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Implement download functionality
            },
            icon:
                const Icon(Icons.download, color: AppColors.eLearningBtnColor1),
            label: const Text(
              'Download',
              style: TextStyle(color: AppColors.eLearningBtnColor1),
            ),
          ),
        ],
      ),
        body: Container(
          decoration:Constants.customScreenDec0ration(),
      width: double.infinity,
      height: double.infinity,
     
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Account',
                style: AppTextStyles.normal600(
                    fontSize: 22, color: AppColors.profileTitle),
              ),
              SizedBox(
                height: 40,
              ),
              profilePicture(),
              Column(
                children: [
                  Text(
                    'Chiamaka Winifred',
                    style: AppTextStyles.normal500(
                        fontSize: 18, color: AppColors.profileTitle),
                  ),
                  Text(
                    'azuhchiramaka2018@gmail.com',
                    style: AppTextStyles.normal400(
                        fontSize: 16, color: AppColors.profileSubTitle),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Divider(),
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit profile information'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Text('Theme'),
                    subtitle: Text('Light'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.remove_circle_outline),
                    title: Text('Remove Ads'),
                    trailing: Switch(
                      activeColor: AppColors.barColor2,
                      inactiveThumbColor: Colors.white10,
                      value: _isAdRemoved,
                      onChanged: (value) {
                        setState(() {
                          _isAdRemoved = value;
                        });
                        print('Ads removed: $value');
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description_rounded),
                    title: Text(
                      'Terms & Conditions',
                      style: AppTextStyles.normal400(
                          fontSize: 16, color: AppColors.profiletext),
                    ),
                 selectedColor: Colors.amber.shade100,
                    onTap: () {
                       print(' Terms & Conditions');
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout_outlined,
                        color: AppColors.profileLogout),
                    title: Text('Logout',
                        style: AppTextStyles.normal400(
                            fontSize: 16, color: AppColors.profileLogout)),
                            onTap: (){},
                  )
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }







  Stack profilePicture() {
    return Stack(
      children: [
        SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image(
              image: AssetImage('assets/images/profile/profile-picture.jpg'),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 5,
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}