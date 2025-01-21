import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/constants.dart';
class SchoolDescriptionScreen extends StatefulWidget {

  
  @override
  _SchoolDescriptionScreenState createState() => _SchoolDescriptionScreenState();
}

class _SchoolDescriptionScreenState extends State<SchoolDescriptionScreen> {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constants.customBoxDecoration(context),
      child: SingleChildScrollView(
          child: Column(
            children: [
              FractionallySizedBox(
                widthFactor: 0.5, 
            heightFactor: 0.3,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/images/explore-images/'))
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
}