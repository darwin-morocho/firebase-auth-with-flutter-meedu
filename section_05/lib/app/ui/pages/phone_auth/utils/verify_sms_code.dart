import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/dialogs/dialogs.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/dialogs/progress_dialog.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/phone_auth_page.dart';

void verifySmsCode(BuildContext context) async {
  ProgressDialog.show(context);
  final controller = phoneAuthProvider.read;
  final error = await controller.validateSmsCode();
  if (error != null) {
    Navigator.pop(context);
    Dialogs.alert(
      context,
      title: error,
    );
  }
}
