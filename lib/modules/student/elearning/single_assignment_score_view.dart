import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:linkschool/modules/model/student/single_elearningcontentmodel.dart';
import 'package:linkschool/modules/model/student/submitted_assignment_model.dart';
import 'package:linkschool/modules/providers/student/marked_assignment_provider.dart';
import 'package:linkschool/modules/student/elearning/resubmit_modal.dart';
import 'package:provider/provider.dart';

import '../../common/app_colors.dart';

class SingleAssignmentScorePage extends StatefulWidget {
  final int year;
  final int term;
  final List<String> attachedMaterials;
  final SingleElearningContentData? childContent;


  const SingleAssignmentScorePage({
    Key? key,
    required this.childContent,
    required this.year,
    required this.term,
    required this.attachedMaterials,

  }) : super(key: key);

  @override
  State<SingleAssignmentScorePage> createState() => _SingleAssignmentScorePageState();
}

class _SingleAssignmentScorePageState extends State<SingleAssignmentScorePage> {
  MarkedAssignmentModel? markedass;
  int? academicTerm;
  int? academicYear;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchMarkedAssignment();
    // Show the modal bottom sheet after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  _showAttachedMaterials();
    });
  }
  Future<void> _loadUserData() async {


    try {
      final userBox = Hive.box('userData');
      final storedUserData = userBox.get('userData') ?? userBox.get('loginResponse');
      if (storedUserData != null) {
        final processedData = storedUserData is String
            ? json.decode(storedUserData)
            : storedUserData as Map<String, dynamic>;
        final response = processedData['response'] ?? processedData;
        final data = response['data'] ?? response;
        final profile = data['profile'] ?? {};
        final settings = data['settings'] ?? {};

        setState(() {
          academicYear = settings['year'];
          academicTerm = settings['term'] ;
        });
      }

    } catch (e) {
      print('Error loading user data: $e');
    }

  }


  void _showAttachedMaterials() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,

      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.20,
        minChildSize: 0.15,
        maxChildSize: 0.6,
        builder: (context, scrollController) {
          return MaterialSheet(
            attachedMaterials: markedass?.files ??[],
            scrollController: scrollController,
          );
        },
      ),
    );
  }
  Future<void> fetchMarkedAssignment() async {
    final provider = Provider.of<MarkedAssignmentProvider>(context, listen: false);
    final data = await provider.fetchMarkedAssignment(widget.childContent?.id  ?? 0, widget.year , widget.term );

    setState(() {
      markedass = data;
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading || markedass== null) {
      return const Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CircularProgressIndicator(),
              Text("Loading your marked assignment" ,style: TextStyle(color: AppColors.paymentBtnColor1),),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.childContent?.title ?? "No Title"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              "Your Score",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "${markedass!.marking_score} / 100",
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _showAttachedMaterials,
            child: const Text("View Attached Materials"),
          ),
        ],
      ),
    );
  }
}