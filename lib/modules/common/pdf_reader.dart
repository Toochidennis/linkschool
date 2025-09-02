import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
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
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
              ? const Center(child: Text("Failed to load PDF"))
              : PDFView(
                  filePath: localPath!,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                ),
    );
  }
}