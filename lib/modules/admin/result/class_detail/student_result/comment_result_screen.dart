import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class CommentResultScreen extends StatefulWidget {
  final String classId;
  final String year;
  final int termId;
  final String termName;

  const CommentResultScreen({
    Key? key,
    required this.classId,
    required this.year,
    required this.termId,
    required this.termName,
  }) : super(key: key);

  @override
  State<CommentResultScreen> createState() => _CommentResultScreenState();
}

class _CommentResultScreenState extends State<CommentResultScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [
    {
      'studentName': 'John Doe',
      'comment': 'Excellent performance in mathematics. Shows great understanding of concepts.',
      'date': '2024-01-15',
      'subject': 'Mathematics',
    },
    {
      'studentName': 'Jane Smith',
      'comment': 'Good improvement in English. Needs to work on essay writing skills.',
      'date': '2024-01-14',
      'subject': 'English',
    },
    {
      'studentName': 'Mike Johnson',
      'comment': 'Outstanding participation in science experiments. Very curious and engaged.',
      'date': '2024-01-13',
      'subject': 'Science',
    },
  ];

  String _selectedStudent = 'Select Student';
  String _selectedSubject = 'Select Subject';

  final List<String> _students = [
    'John Doe',
    'Jane Smith',
    'Mike Johnson',
    'Sarah Wilson',
    'David Brown',
  ];

  final List<String> _subjects = [
    'Mathematics',
    'English',
    'Science',
    'History',
    'Geography',
    'Biology',
    'Chemistry',
    'Physics',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Comment on Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.class_, color: AppColors.iconColor1, size: 20),
                      const SizedBox(width: 8),
                      Text('Class ID: ${widget.classId}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.iconColor2, size: 20),
                      const SizedBox(width: 8),
                      Text('Year: ${widget.year}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: AppColors.iconColor3, size: 20),
                      const SizedBox(width: 8),
                      Text('Term: ${widget.termName}'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Add Comment Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Comment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Student Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedStudent == 'Select Student' ? null : _selectedStudent,
                    decoration: InputDecoration(
                      labelText: 'Select Student',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _students.map((String student) {
                      return DropdownMenuItem<String>(
                        value: student,
                        child: Text(student),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStudent = newValue ?? 'Select Student';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subject Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSubject == 'Select Subject' ? null : _selectedSubject,
                    decoration: InputDecoration(
                      labelText: 'Select Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _subjects.map((String subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubject = newValue ?? 'Select Subject';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Comment TextField
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Comment',
                      hintText: 'Enter your comment about the student\'s performance...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Add Comment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedStudent != 'Select Student' && 
                            _selectedSubject != 'Select Subject' && 
                            _commentController.text.isNotEmpty) {
                          setState(() {
                            _comments.insert(0, {
                              'studentName': _selectedStudent,
                              'comment': _commentController.text,
                              'date': DateTime.now().toString().substring(0, 10),
                              'subject': _selectedSubject,
                            });
                          });
                          _commentController.clear();
                          _selectedStudent = 'Select Student';
                          _selectedSubject = 'Select Subject';
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comment added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bgColor2,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Comment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Comments List
            Text(
              'Recent Comments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment['studentName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bgColor3,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              comment['subject'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.iconColor2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment['comment'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${comment['date']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}