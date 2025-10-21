import 'package:flutter/material.dart';
// This file is kept as a legacy entry point to avoid breaking existing imports.
// It now forwards all field registration to the new FieldDetailsPage implementation.
// See FieldDetailsPage for the current implementation.
import 'field_application_draft.dart';
import 'field_details_page.dart';

@Deprecated('Use FieldDetailsPage directly instead')
class RegisterFieldPage extends StatefulWidget {
  const RegisterFieldPage({super.key});

  @override
  State<RegisterFieldPage> createState() => _RegisterFieldPageState();
}

class _RegisterFieldPageState extends State<RegisterFieldPage> {
  @override
  Widget build(BuildContext context) {
    final draft = FieldApplicationDraft();
    return FieldDetailsPage(draft: draft);
  }
}
