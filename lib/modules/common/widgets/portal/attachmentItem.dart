class AttachmentItem {
  final String? fileName;      // Display name or URL
  final String? iconPath;
  final String? fileContent; 
  final String?  content;
  final bool isExisting;
    final String? originalServerFileName; 
  final String? base64Content; // base64 or URL
  AttachmentItem({
 this.fileName,
    this.iconPath,
    this.fileContent,
    this.content,
    this.isExisting = false, 
       this.originalServerFileName,
    this.base64Content

  });
}