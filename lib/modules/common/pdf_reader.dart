import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  const PdfViewerPage({super.key, required this.url});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool loading = true;
  

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      // Make sure to import: import 'package:path_provider/path_provider.dart';
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/temp.pdf");
        await file.writeAsBytes(response.bodyBytes, flush: true);
        print("ssssssss ${response.body}");
        if (!mounted) return;
        setState(() {
          localPath = file.path;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("PDF download error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
        final isDark = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: Colors.white,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor:AppColors.primaryLight,
        title: const Text("PDF Preview",style: TextStyle(color: Colors.white),)),
      body: loading
          ? const Center(child: CircularProgressIndicator( color: AppColors.primaryLight,))
          : localPath == null
              ? const Center(child: Text("Failed to load PDF"))
              : PDFView(
                  filePath: localPath!,
                  swipeHorizontal:false,
                  autoSpacing: false,
                  pageFling: true,
                  fitEachPage: true,
                  nightMode:isDark == Brightness.dark ?true : false,
                  fitPolicy: FitPolicy.BOTH,
                ),
    );
  }
}