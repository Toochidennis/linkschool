import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class CompositeResultScreen extends StatefulWidget {
  final String classId;
  final String year;
  final int termId;
  final String termName;

  const CompositeResultScreen({
    Key? key,
    required this.classId,
    required this.year,
    required this.termId,
    required this.termName,
  }) : super(key: key);

  @override
  State<CompositeResultScreen> createState() => _CompositeResultScreenState();
}

class _CompositeResultScreenState extends State<CompositeResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedStudentIndex;

  final List<Map<String, dynamic>> _studentResults = [
    {
      'name': 'John Doe',
      'studentId': 'STU001',
      'totalScore': 85.5,
      'grade': 'A',
      'position': 1,
      'subjects': [
        {'name': 'Mathematics', 'score': 88, 'grade': 'A'},
        {'name': 'English', 'score': 82, 'grade': 'B+'},
        {'name': 'Science', 'score': 90, 'grade': 'A'},
        {'name': 'History', 'score': 78, 'grade': 'B'},
        {'name': 'Geography', 'score': 85, 'grade': 'A-'},
      ],
    },
    {
      'name': 'Jane Smith',
      'studentId': 'STU002',
      'totalScore': 82.0,
      'grade': 'A-',
      'position': 2,
      'subjects': [
        {'name': 'Mathematics', 'score': 85, 'grade': 'A-'},
        {'name': 'English', 'score': 88, 'grade': 'A'},
        {'name': 'Science', 'score': 80, 'grade': 'B+'},
        {'name': 'History', 'score': 82, 'grade': 'B+'},
        {'name': 'Geography', 'score': 75, 'grade': 'B'},
      ],
    },
    {
      'name': 'Mike Johnson',
      'studentId': 'STU003',
      'totalScore': 78.5,
      'grade': 'B+',
      'position': 3,
      'subjects': [
        {'name': 'Mathematics', 'score': 75, 'grade': 'B'},
        {'name': 'English', 'score': 80, 'grade': 'B+'},
        {'name': 'Science', 'score': 85, 'grade': 'A-'},
        {'name': 'History', 'score': 78, 'grade': 'B'},
        {'name': 'Geography', 'score': 75, 'grade': 'B'},
      ],
    },
    {
      'name': 'Sarah Wilson',
      'studentId': 'STU004',
      'totalScore': 75.0,
      'grade': 'B',
      'position': 4,
      'subjects': [
        {'name': 'Mathematics', 'score': 72, 'grade': 'B-'},
        {'name': 'English', 'score': 78, 'grade': 'B'},
        {'name': 'Science', 'score': 80, 'grade': 'B+'},
        {'name': 'History', 'score': 75, 'grade': 'B'},
        {'name': 'Geography', 'score': 70, 'grade': 'B-'},
      ],
    },
    {
      'name': 'David Brown',
      'studentId': 'STU005',
      'totalScore': 70.2,
      'grade': 'B-',
      'position': 5,
      'subjects': [
        {'name': 'Mathematics', 'score': 68, 'grade': 'C+'},
        {'name': 'English', 'score': 72, 'grade': 'B-'},
        {'name': 'Science', 'score': 75, 'grade': 'B'},
        {'name': 'History', 'score': 70, 'grade': 'B-'},
        {'name': 'Geography', 'score': 66, 'grade': 'C+'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'A-':
        return Colors.green.shade300;
      case 'B+':
        return Colors.blue;
      case 'B':
        return Colors.blue.shade300;
      case 'B-':
        return Colors.orange;
      case 'C+':
        return Colors.orange.shade300;
      case 'C':
        return Colors.red.shade300;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOverviewTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _studentResults.length,
      itemBuilder: (context, index) {
        final student = _studentResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedStudentIndex = index;
                _tabController.animateTo(1); // Go to Details tab
              });
            },
            child: Row(
              children: [
                // Position Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: student['position'] == 1 
                        ? Colors.amber 
                        : student['position'] == 2 
                            ? Colors.grey 
                            : student['position'] == 3 
                                ? Colors.brown 
                                : AppColors.bgColor4,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${student['position']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${student['studentId']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Score and Grade
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${student['totalScore']}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getGradeColor(student['grade']),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        student['grade'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsTab() {
    if (_selectedStudentIndex == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Please select a student from the overview tab to view details',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final student = _studentResults[_selectedStudentIndex!];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bgColor2, AppColors.bgColor3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    student['name'][0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.iconColor1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  student['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Student ID: ${student['studentId']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${student['totalScore']}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Total Score',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          student['grade'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Grade',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${student['position']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Position',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Subject Results
          Text(
            'Subject Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          ...student['subjects'].map<Widget>((subject) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: subject['score'] / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getGradeColor(subject['grade']),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${subject['score']}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getGradeColor(subject['grade']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subject['grade'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    // Calculate class statistics
    double classAverage = _studentResults
        .map((s) => s['totalScore'] as double)
        .reduce((a, b) => a + b) / _studentResults.length;
    
    Map<String, int> gradeDistribution = {};
    for (var student in _studentResults) {
      String grade = student['grade'];
      gradeDistribution[grade] = (gradeDistribution[grade] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Statistics Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Total Students', '${_studentResults.length}', Icons.people, AppColors.bgColor2),
                    _buildStatCard('Class Average', '${classAverage.toStringAsFixed(1)}%', Icons.trending_up, AppColors.bgColor3),
                    _buildStatCard('Highest Score', '${_studentResults.first['totalScore']}%', Icons.star, AppColors.bgColor4),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Grade Distribution
          Text(
            'Grade Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: gradeDistribution.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _getGradeColor(entry.key),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: entry.value / _studentResults.length,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getGradeColor(entry.key),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${entry.value} students',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Composite Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.iconColor1,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.iconColor1,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Details'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Class Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.class_, color: AppColors.iconColor1, size: 20),
                const SizedBox(width: 8),
                Text('Class: ${widget.classId}'),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, color: AppColors.iconColor2, size: 20),
                const SizedBox(width: 8),
                Text('${widget.year} - ${widget.termName}'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDetailsTab(),
                _buildStatisticsTab(),
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

// class CompositeResultScreen extends StatefulWidget {
//   final String classId;
//   final String year;
//   final int termId;
//   final String termName;

//   const CompositeResultScreen({
//     Key? key,
//     required this.classId,
//     required this.year,
//     required this.termId,
//     required this.termName,
//   }) : super(key: key);

//   @override
//   State<CompositeResultScreen> createState() => _CompositeResultScreenState();
// }

// class _CompositeResultScreenState extends State<CompositeResultScreen> {
//   final List<Map<String, dynamic>> _studentResults = [
//     {
//       'name': 'John Doe',
//       'studentId': 'STU001',
//       'totalScore': 85.5,
//       'grade': 'A',
//       'position': 1,
//       'subjects': [
//         {'name': 'Mathematics', 'score': 88, 'grade': 'A'},
//         {'name': 'English', 'score': 82, 'grade': 'B+'},
//         {'name': 'Science', 'score': 90, 'grade': 'A'},
//         {'name': 'History', 'score': 78, 'grade': 'B'},
//         {'name': 'Geography', 'score': 85, 'grade': 'A-'},
//       ],
//     },
//     {
//       'name': 'Jane Smith',
//       'studentId': 'STU002',
//       'totalScore': 82.0,
//       'grade': 'A-',
//       'position': 2,
//       'subjects': [
//         {'name': 'Mathematics', 'score': 85, 'grade': 'A-'},
//         {'name': 'English', 'score': 88, 'grade': 'A'},
//         {'name': 'Science', 'score': 80, 'grade': 'B+'},
//         {'name': 'History', 'score': 82, 'grade': 'B+'},
//         {'name': 'Geography', 'score': 75, 'grade': 'B'},
//       ],
//     },
//     {
//       'name': 'Mike Johnson',
//       'studentId': 'STU003',
//       'totalScore': 78.5,
//       'grade': 'B+',
//       'position': 3,
//       'subjects': [
//         {'name': 'Mathematics', 'score': 75, 'grade': 'B'},
//         {'name': 'English', 'score': 80, 'grade': 'B+'},
//         {'name': 'Science', 'score': 85, 'grade': 'A-'},
//         {'name': 'History', 'score': 78, 'grade': 'B'},
//         {'name': 'Geography', 'score': 75, 'grade': 'B'},
//       ],
//     },
//     {
//       'name': 'Sarah Wilson',
//       'studentId': 'STU004',
//       'totalScore': 75.0,
//       'grade': 'B',
//       'position': 4,
//       'subjects': [
//         {'name': 'Mathematics', 'score': 72, 'grade': 'B-'},
//         {'name': 'English', 'score': 78, 'grade': 'B'},
//         {'name': 'Science', 'score': 80, 'grade': 'B+'},
//         {'name': 'History', 'score': 75, 'grade': 'B'},
//         {'name': 'Geography', 'score': 70, 'grade': 'B-'},
//       ],
//     },
//     {
//       'name': 'David Brown',
//       'studentId': 'STU005',
//       'totalScore': 70.2,
//       'grade': 'B-',
//       'position': 5,
//       'subjects': [
//         {'name': 'Mathematics', 'score': 68, 'grade': 'C+'},
//         {'name': 'English', 'score': 72, 'grade': 'B-'},
//         {'name': 'Science', 'score': 75, 'grade': 'B'},
//         {'name': 'History', 'score': 70, 'grade': 'B-'},
//         {'name': 'Geography', 'score': 66, 'grade': 'C+'},
//       ],
//     },
//   ];

//   String _selectedView = 'Overview';
//   int? _selectedStudentIndex;

//   Color _getGradeColor(String grade) {
//     switch (grade.toUpperCase()) {
//       case 'A':
//         return Colors.green;
//       case 'A-':
//         return Colors.green.shade300;
//       case 'B+':
//         return Colors.blue;
//       case 'B':
//         return Colors.blue.shade300;
//       case 'B-':
//         return Colors.orange;
//       case 'C+':
//         return Colors.orange.shade300;
//       case 'C':
//         return Colors.red.shade300;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildOverviewTab() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _studentResults.length,
//       itemBuilder: (context, index) {
//         final student = _studentResults[index];
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 _selectedStudentIndex = index;
//                 _selectedView = 'Details';
//               });
//             },
//             child: Row(
//               children: [
//                 // Position Badge
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: student['position'] == 1 
//                         ? Colors.amber 
//                         : student['position'] == 2 
//                             ? Colors.blueGrey 
//                             : student['position'] == 3 
//                                 ? Colors.brown 
//                                 : AppColors.bgColor4,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${student['position']}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
                
//                 // Student Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         student['name'],
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'ID: ${student['studentId']}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Score and Grade
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '${student['totalScore']}%',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: _getGradeColor(student['grade']),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         student['grade'],
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDetailsTab() {
//     if (_selectedStudentIndex == null) {
//       return const Center(
//         child: Text('Please select a student from the overview tab'),
//       );
//     }

//     final student = _studentResults[_selectedStudentIndex!];
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Student Header Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.bgColor2, AppColors.bgColor3],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     student['name'][0],
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.iconColor1,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   student['name'],
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Student ID: ${student['studentId']}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Column(
//                       children: [
//                         Text(
//                           '${student['totalScore']}%',
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const Text(
//                           'Total Score',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Text(
//                           student['grade'],
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const Text(
//                           'Grade',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Text(
//                           '${student['position']}',
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const Text(
//                           'Position',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 20),
          
//           // Subject Results
//           Text(
//             'Subject Performance',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: student['subjects'].length,
//             itemBuilder: (context, index) {
//               final subject = student['subjects'][index];
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 4,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             subject['name'],
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Container(
//                             width: double.infinity,
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(3),
//                             ),
//                             child: FractionallySizedBox(
//                               alignment: Alignment.centerLeft,
//                               widthFactor: subject['score'] / 100,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: _getGradeColor(subject['grade']),
//                                   borderRadius: BorderRadius.circular(3),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           '${subject['score']}%',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: _getGradeColor(subject['grade']),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             subject['grade'],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsTab() {
//     // Calculate class statistics
//     double classAverage = _studentResults
//         .map((s) => s['totalScore'] as double)
//         .reduce((a, b) => a + b) / _studentResults.length;
    
//     Map<String, int> gradeDistribution = {};
//     for (var student in _studentResults) {
//       String grade = student['grade'];
//       gradeDistribution[grade] = (gradeDistribution[grade] ?? 0) + 1;
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Class Statistics Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Class Statistics',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildStatCard('Total Students', '${_studentResults.length}', Icons.people, AppColors.bgColor2),
//                     _buildStatCard('Class Average', '${classAverage.toStringAsFixed(1)}%', Icons.trending_up, AppColors.bgColor3),
//                     _buildStatCard('Highest Score', '${_studentResults.first['totalScore']}%', Icons.star, AppColors.bgColor4),
//                   ],
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 20),
          
//           // Grade Distribution
//           Text(
//             'Grade Distribution',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: gradeDistribution.entries.map((entry) {
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: _getGradeColor(entry.key),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Center(
//                           child: Text(
//                             entry.key,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Container(
//                           height: 20,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: FractionallySizedBox(
//                             alignment: Alignment.centerLeft,
//                             widthFactor: entry.value / _studentResults.length,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: _getGradeColor(entry.key),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         '${entry.value} students',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Composite Results',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         foregroundColor: Colors.black,
//         actions: [
//           if (_selectedView == 'Details')
//             IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () {
//                 setState(() {
//                   _selectedView = 'Overview';
//                   _selectedStudentIndex = null;
//                 });
//               },
//             ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(48),
//           child: Container(
//             color: Colors.white,
//             child: TabBar(
//               controller: null,
//               isScrollable: true,
//               labelColor: AppColors.iconColor1,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: AppColors.iconColor1,
//               tabs: const [
//                 Tab(text: 'Overview'),
//                 Tab(text: 'Details'),
//                 Tab(text: 'Statistics'),
//               ],
//               onTap: (index) {
//                 setState(() {
//                   switch (index) {
//                     case 0:
//                       _selectedView = 'Overview';
//                       break;
//                     case 1:
//                       _selectedView = 'Details';
//                       break;
//                     case 2:
//                       _selectedView = 'Statistics';
//                       break;
//                   }
//                 });
//               },
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Class Info Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Icon(Icons.class_, color: AppColors.iconColor1, size: 20),
//                 const SizedBox(width: 8),
//                 Text('Class: ${widget.classId}'),
//                 const SizedBox(width: 16),
//                 Icon(Icons.calendar_today, color: AppColors.iconColor2, size: 20),
//                 const SizedBox(width: 8),
//                 Text('${widget.year} - ${widget.termName}'),
//               ],
//             ),
//           ),
          
//           // Content based on selected view
//           Expanded(
//             child: _selectedView == 'Overview'
//                 ? _buildOverviewTab()
//                 : _selectedView == 'Details'
//                     ? _buildDetailsTab()
//                     : _buildStatisticsTab(),
//           ),
//         ],
//       ),
//     );
//   }
// }