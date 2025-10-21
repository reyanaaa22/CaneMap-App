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
      appBar: AppBar(
        title: const Text('Required Documents'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Required Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide clear photos of your documents',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            _buildDocumentCard(
              'Barangay Certificate',
              'Official barangay clearance document',
              Icons.description_outlined,
              widget.draft.barangayCert?.name,
              () async {
                widget.draft.barangayCert = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _buildDocumentCard(
              'Land Title',
              'Original or certified copy of land title',
              Icons.home_work_outlined,
              widget.draft.landTitle?.name,
              () async {
                widget.draft.landTitle = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                setState(() {});
              },
            ),
            const Spacer(),
            _buildProgressIndicator(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.draft.barangayCert == null ||
                          widget.draft.landTitle == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please upload both documents to continue',
                            ),
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
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    String title,
    String description,
    IconData icon,
    String? filename,
    Future<void> Function() onTap,
  ) {
    final isUploaded = filename != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? Colors.green.shade300 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUploaded ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isUploaded ? Colors.green.shade700 : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUploaded)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
              ],
            ),
            if (isUploaded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final barangayUploaded = widget.draft.barangayCert != null;
    final landTitleUploaded = widget.draft.landTitle != null;
    final progress = (barangayUploaded ? 1 : 0) + (landTitleUploaded ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$progress/2 documents',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress / 2,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          ),
        ),
      ],
    );
  }
}
