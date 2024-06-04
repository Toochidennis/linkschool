import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkschool/common/text_styles.dart';

import '../../../common/app_colors.dart';

class ExploreHome extends StatefulWidget {
  const ExploreHome({super.key});

  @override
  State<ExploreHome> createState() => _ExploreHomeState();
}

class _ExploreHomeState extends State<ExploreHome> {
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    var opacity = brightness == Brightness.light ? 0.1 : 0.15;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/img.png'),
            fit: BoxFit.cover,
            opacity: opacity),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search',
                    labelStyle: TextStyle(
                      fontSize: 14.0,
                      color: Color.fromRGBO(139, 139, 139, 1),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: AppColors.textFieldLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16.0),
                      ),
                      gapPadding: 4.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Image.asset(
                      'assets/images/millionaire.png',
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Millionaire Game',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text('By Digital Dreams',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),

                        ),
                        child: Text('Play', style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Urbanist'
                        ),),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
