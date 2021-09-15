import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/dialogs/dialogs.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/dialogs/progress_dialog.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/phone_auth_page.dart';

void requestSmsCode(BuildContext context) async {
  ProgressDialog.show(context);
  final controller = phoneAuthProvider.read;
  final error = await controller.requestCode();
  Navigator.pop(context);
  if (error != null) {
    Dialogs.alert(
      context,
      title: error,
    );
  }
}
