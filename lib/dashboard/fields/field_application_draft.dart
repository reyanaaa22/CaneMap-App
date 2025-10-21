import 'package:image_picker/image_picker.dart';

class FieldApplicationDraft {
  String? fieldName;
  String? sizeHa;
  String? barangay;
  String? municipality;
  String? cropVariety;
  String? address;
  String? terrain;
  String? lat;
  String? lng;

  XFile? barangayCert;
  XFile? landTitle;
  XFile? idFront;
  XFile? idBack;
  XFile? selfie;

  Map<String, dynamic> summary() => {
    'name': fieldName,
    'sizeHa': sizeHa,
    'barangay': barangay,
    'municipality': municipality,
    'address': address,
    'lat': lat,
    'lng': lng,
    'terrain': terrain,
    'variety': cropVariety,
    'files': {
      'barangayCert': barangayCert?.path,
      'landTitle': landTitle?.path,
      'idFront': idFront?.path,
      'idBack': idBack?.path,
      'selfie': selfie?.path,
    },
  };
}
