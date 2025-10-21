import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'field_application_draft.dart';

class IdsCameraPage extends StatefulWidget {
  final FieldApplicationDraft draft;
  const IdsCameraPage({super.key, required this.draft});

  @override
  State<IdsCameraPage> createState() => _IdsCameraPageState();
}

class _IdsCameraPageState extends State<IdsCameraPage> {
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture Your Identity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take clear photos of your ID and a selfie for verification',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            _buildCaptureCard(
              'Valid ID (Front)',
              'Clear photo of your ID front',
              Icons.credit_card_outlined,
              widget.draft.idFront?.name,
              () async {
                widget.draft.idFront = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _buildCaptureCard(
              'Valid ID (Back)',
              'Clear photo of your ID back',
              Icons.credit_card_outlined,
              widget.draft.idBack?.name,
              () async {
                widget.draft.idBack = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _buildCaptureCard(
              'Selfie Holding Your ID',
              'Your face with ID clearly visible',
              Icons.face_outlined,
              widget.draft.selfie?.name,
              () async {
                widget.draft.selfie = await _picker.pickImage(
                  source: ImageSource.camera,
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
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit',
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

  Future<void> _submit() async {
    if (widget.draft.idFront == null ||
        widget.draft.idBack == null ||
        widget.draft.selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture all three photos to submit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final applicantName = user.displayName ?? user.email ?? 'Applicant';
      final userId = user.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Upload images to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final userFolder = storageRef.child('field_applications/$userId');

      // Upload ID Front
      final idFrontRef = userFolder.child('valid_front_$timestamp.png');
      await idFrontRef.putFile(File(widget.draft.idFront!.path));
      final validFrontUrl = await idFrontRef.getDownloadURL();

      // Upload ID Back
      final idBackRef = userFolder.child('valid_back_$timestamp.png');
      await idBackRef.putFile(File(widget.draft.idBack!.path));
      final validBackUrl = await idBackRef.getDownloadURL();

      // Upload Selfie
      final selfieRef = userFolder.child('selfie_$timestamp.png');
      await selfieRef.putFile(File(widget.draft.selfie!.path));
      final selfieUrl = await selfieRef.getDownloadURL();

      // Save application data to Firestore
      await FirebaseFirestore.instance.collection('field_applications').add({
        'applicantName': applicantName,
        'userId': userId,
        'requestedBy': userId,
        'barangay': widget.draft.barangay,
        'crop_variety': widget.draft.cropVariety,
        'field_size': widget.draft.sizeHa,
        'latitude': double.tryParse(widget.draft.lat ?? '0') ?? 0,
        'longitude': double.tryParse(widget.draft.lng ?? '0') ?? 0,
        'validFrontUrl': validFrontUrl,
        'validBackUrl': validBackUrl,
        'selfieUrl': selfieUrl,
        'status': 'pending',
        'submittedAt': DateTime.now(),
        'statusUpdatedAt': DateTime.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pop(widget.draft.summary());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildCaptureCard(
    String title,
    String description,
    IconData icon,
    String? filename,
    Future<void> Function() onTap,
  ) {
    final isCaptured = filename != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isCaptured ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCaptured ? Colors.green.shade300 : Colors.grey.shade300,
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
                    color: isCaptured ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isCaptured ? Colors.green.shade700 : Colors.grey.shade600,
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
                if (isCaptured)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
              ],
            ),
            if (isCaptured) ...[
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
    final idFrontCaptured = widget.draft.idFront != null;
    final idBackCaptured = widget.draft.idBack != null;
    final selfieCaptured = widget.draft.selfie != null;
    final progress = (idFrontCaptured ? 1 : 0) + (idBackCaptured ? 1 : 0) + (selfieCaptured ? 1 : 0);

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
              '$progress/3 photos',
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
            value: progress / 3,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          ),
        ),
      ],
    );
  }
}
