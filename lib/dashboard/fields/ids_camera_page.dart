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
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAF7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1B4332)),
        title: const Text(
          'Identity Verification',
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
                title: 'Capture Your Identity',
                subtitle: 'Take clear photos of your ID and a selfie for verification.',
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCaptureCard(
                        'Valid ID (Front)',
                        'Clear photo of your ID front',
                        Icons.credit_card_outlined,
                        widget.draft.idFront?.name,
                        accent: const Color(0xFF2F8F46),
                        () async {
                          widget.draft.idFront = await _picker.pickImage(
                            source: ImageSource.camera,
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildCaptureCard(
                        'Valid ID (Back)',
                        'Clear photo of your ID back',
                        Icons.credit_card_outlined,
                        widget.draft.idBack?.name,
                        accent: const Color(0xFF1E88E5),
                        () async {
                          widget.draft.idBack = await _picker.pickImage(
                            source: ImageSource.camera,
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildCaptureCard(
                        'Selfie Holding Your ID',
                        'Your face with ID clearly visible',
                        Icons.face_outlined,
                        widget.draft.selfie?.name,
                        accent: const Color(0xFFFB8C00),
                        () async {
                          widget.draft.selfie = await _picker.pickImage(
                            source: ImageSource.camera,
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
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F8F46),
                        disabledBackgroundColor: const Color(0xFFB0BEC5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFF2F8F46).withOpacity(0.35),
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

  Widget _buildStatusIcon(bool completed, Color accent) {
    if (completed) {
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
      child: Icon(Icons.camera_alt_outlined, size: 16, color: Colors.grey.shade500),
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

  Widget _buildCaptureCard(
    String title,
    String description,
    IconData icon,
    String? filename,
    Future<void> Function() onTap, {
    Color accent = const Color(0xFF2F8F46),
  }) {
    final capturedName = filename;
    final isCaptured = capturedName != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCaptured ? accent.withOpacity(0.45) : Colors.transparent,
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
                color: accent.withOpacity(isCaptured ? 0.18 : 0.1),
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
                      _buildStatusIcon(isCaptured, accent),
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
                  if (capturedName != null) ...[
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
                          Icon(Icons.insert_photo_outlined, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              capturedName,
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
