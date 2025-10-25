import 'package:flutter/material.dart';

class DriverBadgeApplication extends StatefulWidget {
  const DriverBadgeApplication({super.key});

  @override
  State<DriverBadgeApplication> createState() => _DriverBadgeApplicationState();
}

class _DriverBadgeApplicationState extends State<DriverBadgeApplication> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Personal Information
  final _fullNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();

  // License Details
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();

  // Vehicle Information
  final _vehiclePlateController = TextEditingController();
  final _vehicleTypeController = TextEditingController();

  // Attachments
  String? _licensePhotoPath;
  String? _idPhotoPath;
  String? _vehicleDocPath;

  bool _certificationAccepted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _vehiclePlateController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (_formKey.currentState!.validate() && _certificationAccepted) {
      _showSuccessDialog();
    } else if (!_certificationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the certification to proceed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '✓ Application Submitted',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2F8F46),
          ),
        ),
        content: const Text(
          'Your driver badge application has been submitted successfully. We will review your information and contact you within 3-5 business days.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F8F46),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F7F3),
        automaticallyImplyLeading: true,
        elevation: 0,
        title: const Text(
          'Driver Badge Application',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.25,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 24),

              // Step Content
              if (_currentStep == 0) _buildPersonalInformationStep(),
              if (_currentStep == 1) _buildLicenseDetailsStep(),
              if (_currentStep == 2) _buildVehicleInformationStep(),
              if (_currentStep == 3) _buildAttachmentsStep(),
              if (_currentStep == 4) _buildCertificationStep(),

              const SizedBox(height: 24),

              // Navigation Buttons
              _buildNavigationButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_currentStep + 1} of 5',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2F8F46).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${((_currentStep + 1) / 5 * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F8F46),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF2F8F46),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('Personal Information'),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _fullNameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Full name is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _contactNumberController,
          label: 'Contact Number',
          hint: 'Enter your contact number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Contact number is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter your complete address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Address is required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLicenseDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('License Details'),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _licenseNumberController,
          label: 'Driver\'s License Number',
          hint: 'Enter your license number',
          icon: Icons.card_membership_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'License number is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _licenseExpiryController,
          label: 'License Expiry Date',
          hint: 'MM/DD/YYYY',
          icon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.datetime,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Expiry date is required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVehicleInformationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('Vehicle Information'),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _vehiclePlateController,
          label: 'Vehicle Plate Number',
          hint: 'Enter vehicle plate number',
          icon: Icons.directions_car_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Plate number is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _vehicleTypeController,
          label: 'Vehicle Type',
          hint: 'e.g., Motorcycle, Truck, Car',
          icon: Icons.two_wheeler_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Vehicle type is required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAttachmentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('Attachments'),
        const SizedBox(height: 16),
        _buildAttachmentCard(
          title: 'Valid Driver\'s License (Photo)',
          subtitle: 'Upload a clear photo of your driver\'s license',
          icon: Icons.card_membership_outlined,
          isUploaded: _licensePhotoPath != null,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File picker would open here'),
                duration: Duration(seconds: 1),
              ),
            );
            setState(() => _licensePhotoPath = 'license_photo.jpg');
          },
        ),
        const SizedBox(height: 12),
        _buildAttachmentCard(
          title: '1x1 or 2x2 Photo',
          subtitle: 'Recent passport-style photo',
          icon: Icons.photo_outlined,
          isUploaded: _idPhotoPath != null,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File picker would open here'),
                duration: Duration(seconds: 1),
              ),
            );
            setState(() => _idPhotoPath = 'id_photo.jpg');
          },
        ),
        const SizedBox(height: 12),
        _buildAttachmentCard(
          title: 'DR/CR of Vehicle (if applicable)',
          subtitle: 'Vehicle registration or certificate of registration',
          icon: Icons.description_outlined,
          isUploaded: _vehicleDocPath != null,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File picker would open here'),
                duration: Duration(seconds: 1),
              ),
            );
            setState(() => _vehicleDocPath = 'vehicle_doc.pdf');
          },
        ),
      ],
    );
  }

  Widget _buildCertificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle('Certification'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFDCE9E1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8F46),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certification',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2F5E1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'I hereby certify that the above information is true and correct to the best of my knowledge. I understand that providing false information may result in rejection of my application.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: _certificationAccepted,
                  onChanged: (value) {
                    setState(() => _certificationAccepted = value ?? false);
                  },
                  title: const Text(
                    'I agree and certify the information above',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF2F8F46),
                  checkColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF2F8F46),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2F8F46),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAttachmentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF2F8F46)
                : Colors.grey.shade300,
            width: isUploaded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFF2F8F46).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : icon,
                color: isUploaded
                    ? const Color(0xFF2F8F46)
                    : Colors.grey.shade400,
                size: 22,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded ? 'File uploaded' : subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUploaded
                          ? const Color(0xFF2F8F46)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.check : Icons.upload_outlined,
              size: 20,
              color: isUploaded
                  ? const Color(0xFF2F8F46)
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() => _currentStep--);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF2F8F46),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F8F46),
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else {
                _submitApplication();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F8F46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
              shadowColor: const Color(0xFF2F8F46).withOpacity(0.3),
            ),
            child: Text(
              _currentStep == 4 ? 'Submit Application' : 'Next',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
