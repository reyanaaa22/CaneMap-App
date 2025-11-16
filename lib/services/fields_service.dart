import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

/// Model class for field pins on the map
class FieldPin {
  final String id;
  final String fieldName;
  final String applicantName;
  final double latitude;
  final double longitude;
  final String barangay;
  final String municipality;
  final String? sizeHa;
  final String? cropVariety;
  final LatLng location;

  FieldPin({
    required this.id,
    required this.fieldName,
    required this.applicantName,
    required this.latitude,
    required this.longitude,
    required this.barangay,
    required this.municipality,
    this.sizeHa,
    this.cropVariety,
    required this.location,
  });

  factory FieldPin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // documents may use 'lat'/'lng' or 'latitude'/'longitude'
    final lat =
        ((data['latitude'] as num?) ?? (data['lat'] as num?))?.toDouble() ??
            0.0;
    final lng =
        ((data['longitude'] as num?) ?? (data['lng'] as num?))?.toDouble() ??
            0.0;

    print(
        'FieldPin.fromFirestore: id=${doc.id}, lat=$lat, lng=$lng, data keys=${data.keys.toList()}');

    return FieldPin(
      id: doc.id,
      fieldName: data['fieldName'] ??
          data['field_name'] ??
          data['name'] ??
          'Unknown Field',
      applicantName:
          data['applicantName'] ?? data['applicant_name'] ?? 'Unknown',
      latitude: lat,
      longitude: lng,
      barangay: data['barangay'] ?? data['brgy'] ?? 'N/A',
      municipality: data['municipality'] ?? data['municipal'] ?? 'N/A',
      sizeHa: data['size']?.toString() ??
          data['sizeHa'] ??
          data['field_size']?.toString(),
      cropVariety: data['crop_variety'] ?? data['cropVariety'] ?? 'N/A',
      location: LatLng(lat, lng),
    );
  }

  @override
  String toString() =>
      '$fieldName - $barangay, $municipality (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
}

class FieldsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch all registered fields for the current user
  static Future<List<FieldPin>> fetchUserFields() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('fields')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => FieldPin.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching fields: $e');
      rethrow;
    }
  }

  /// Fetch all approved registered fields
  static Future<List<FieldPin>> fetchAllApprovedFields() async {
    try {
      final querySnapshot = await _firestore
          .collection('fields')
          .where('status', isEqualTo: 'approved')
          .get();

      return querySnapshot.docs
          .map((doc) => FieldPin.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching all fields: $e');
      rethrow;
    }
  }

  /// Stream of user's fields for real-time updates. If no user signed in, stream all fields.
  static Stream<List<FieldPin>> streamUserFields() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print(
            'FieldsService: No user signed in - streaming all fields instead');
        return streamAllFields();
      }

      print('FieldsService: Starting stream for userId=$userId');

      return _firestore
          .collection('fields')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        print(
            'FieldsService: Received snapshot with ${snapshot.docs.length} docs');
        final fields = snapshot.docs.map((doc) {
          print('FieldsService: Doc data: ${doc.data()}');
          return FieldPin.fromFirestore(doc);
        }).toList();
        print('FieldsService: Mapped to ${fields.length} FieldPin objects');
        return fields;
      });
    } catch (e) {
      print('Error streaming fields: $e');
      rethrow;
    }
  }

  /// Stream of all approved fields
  static Stream<List<FieldPin>> streamAllApprovedFields() {
    try {
      return _firestore
          .collection('fields')
          .where('status', isEqualTo: 'approved')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => FieldPin.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error streaming all approved fields: $e');
      rethrow;
    }
  }

  /// Stream all documents in the `fields` collection
  static Stream<List<FieldPin>> streamAllFields() {
    try {
      return _firestore.collection('fields').snapshots().map((snapshot) {
        print(
            'FieldsService: streamAllFields received ${snapshot.docs.length} docs');
        final fields = snapshot.docs.map((doc) {
          print('FieldsService: Doc data (all): ${doc.data()}');
          return FieldPin.fromFirestore(doc);
        }).toList();
        print(
            'FieldsService: streamAllFields mapped to ${fields.length} FieldPin objects');
        return fields;
      });
    } catch (e) {
      print('Error streaming all fields: $e');
      rethrow;
    }
  }
}
