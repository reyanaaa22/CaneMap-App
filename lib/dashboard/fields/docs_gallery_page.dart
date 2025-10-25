import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'field_application_draft.dart';
import 'ids_camera_page.dart';

class DocsGalleryPage extends StatefulWidget {
  final FieldApplicationDraft draft;
  const DocsGalleryPage({super.key, required this.draft});

  @override
  State<DocsGalleryPage> createState() => _DocsGalleryPageState();
}

class _DocsGalleryPageState extends State<DocsGalleryPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAF7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
        title: const Text(
          'Required Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B4332),
            letterSpacing: 0.25,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntro(
                title: 'Upload Required Documents',
                subtitle: 'Please provide clear photos of your documents.',
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDocumentCard(
                        'Barangay Certificate',
                        'Official barangay clearance document',
                        Icons.description_outlined,
                        widget.draft.barangayCert?.name,
                        accent: const Color(0xFF2F8F46),
                        () async {
                          widget.draft.barangayCert = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildDocumentCard(
                        'Land Title',
                        'Original or certified copy of land title',
                        Icons.home_work_outlined,
                        widget.draft.landTitle?.name,
                        accent: const Color(0xFF1E88E5),
                        () async {
                          widget.draft.landTitle = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildProgressIndicator(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFB0BEC5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF546E7A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.draft.barangayCert == null ||
                            widget.draft.landTitle == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload both documents to continue'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) => IdsCameraPage(draft: widget.draft),
                          ),
                        )
                            .then((result) {
                          if (result != null) {
                            if (!mounted) return;
                            Navigator.of(context).pop(result);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F8F46),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFF2F8F46).withOpacity(0.35),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B4332),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.3,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    String title,
    String description,
    IconData icon,
    String? filename,
    Future<void> Function() onTap, {
    Color accent = const Color(0xFF2F8F46),
  }) {
    final uploadedName = filename;
    final isUploaded = uploadedName != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUploaded ? accent.withOpacity(0.45) : Colors.transparent,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(isUploaded ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                      ),
                      _buildStatusIcon(isUploaded, accent),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                  if (uploadedName != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.insert_drive_file, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              uploadedName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool uploaded, Color accent) {
    if (uploaded) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, size: 16, color: accent),
      );
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.grey.shade500),
    );
  }

  Widget _buildProgressIndicator() {
    final barangayUploaded = widget.draft.barangayCert != null;
    final landTitleUploaded = widget.draft.landTitle != null;
    final progress = (barangayUploaded ? 1 : 0) + (landTitleUploaded ? 1 : 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4332),
                ),
              ),
              Text(
                '$progress/2 documents',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F8F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 2,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2F8F46)),
            ),
          ),
        ],
      ),
    );
  }
}
