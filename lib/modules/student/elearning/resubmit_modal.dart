import 'package:flutter/material.dart';
import 'package:linkschool/modules/student/elearning/pdf_reader.dart';

import '../../model/student/submitted_assignment_model.dart';

class MaterialSheet extends StatelessWidget {
  final List<SubmittedAssignmentFile> attachedMaterials;
  final ScrollController scrollController;

  const MaterialSheet({
    Key? key,
    required this.attachedMaterials,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ( attachedMaterials== null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: attachedMaterials.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.blue),
            title: Text(attachedMaterials[index].fileName),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewerPage(url:"https://linkskool.net/${attachedMaterials[index].fileName}"),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
