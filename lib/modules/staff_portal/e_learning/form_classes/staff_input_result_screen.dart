import 'package:flutter/material.dart';

class StaffInputResultScreen extends StatelessWidget {
  const StaffInputResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Civic Education Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fixed Student Name Column
                        Container(
                          width: 150, // Adjust width as needed
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                            color: Colors.blue[50],
                          ),
                          child: Column(
                            children: [
                              // Header for Student Name
                              Container(
                                height: 56, // Match DataTable header height
                                alignment: Alignment.center,
                                child: Text(
                                  'Student Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              // Student Names
                              ...List.generate(10, (index) => 
                                Container(
                                  height: 52, // Match DataTable row height
                                  alignment: Alignment.center,
                                  child: Text(
                                    [
                                      'John Doe',
                                      'Emma Smith',
                                      'Michael Johnson',
                                      'Sarah Williams',
                                      'David Brown',
                                      'Lisa Taylor',
                                      'James Anderson',
                                      'Maria Garcia',
                                      'Robert Miller',
                                      'Jennifer Wilson'
                                    ][index],
                                    style: TextStyle(color: Colors.black87),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                        
                        // Scrollable Columns
                        DataTable(
                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[50]!),
                          columnSpacing: 16.0,
                          horizontalMargin: 0,
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.grey.shade300),
                          ),
                          columns: const [
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(
                                  'Attendance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(
                                  'Assessment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(
                                  'Examination',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text(
                                  'Grade',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            10, // Number of rows
                            (index) => DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: _EditableCell(initialValue: '2'),
                                  )
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: _EditableCell(initialValue: '2'),
                                  )
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: _EditableCell(initialValue: '2'),
                                  )
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: _EditableCell(initialValue: '6'),
                                  )
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: _EditableCell(initialValue: 'A'),
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add save logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableCell extends StatefulWidget {
  final String initialValue;

  const _EditableCell({required this.initialValue, Key? key}) : super(key: key);

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: _isEditing
          ? TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (_) {
                setState(() {
                  _isEditing = false;
                });
              },
            )
          : Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                _controller.text,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}