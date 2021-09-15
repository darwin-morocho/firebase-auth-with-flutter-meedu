import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/ui/global_controllers/session_controller.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/widgets/phone_number_view.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/widgets/sms_code_view.dart';
import 'package:flutter_meedu/state.dart';

import 'controller/phone_auth_controller.dart';
import 'controller/phone_auth_state.dart';
import 'widgets/numeric_keyboard.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/router.dart' as router;

final phoneAuthProvider = StateProvider<PhoneAuthController, PhoneAuthState>(
  (_) => PhoneAuthController(sessionProvider.read),
);

class PhoneAuthPage extends StatelessWidget {
  const PhoneAuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderListener<PhoneAuthController>(
      provider: phoneAuthProvider,
      onChange: (_, controller) {
        final routeName = controller.state.routeName;
        if (routeName != null) {
          router.pushNamedAndRemoveUntil(routeName);
        }
      },
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          leading: Consumer(
            builder: (_, ref, __) {
              final codeSent = ref.select(
                phoneAuthProvider.select((_) => _.codeSent),
              );

              return IconButton(
                onPressed: () {
                  if (codeSent) {
                    phoneAuthProvider.read.backToPhoneNumber();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  codeSent ? Icons.arrow_back_rounded : Icons.close_rounded,
                  size: 35,
                ),
              );
            },
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Consumer(
                builder: (_, ref, __) {
                  final codeSent = ref.select(
                    phoneAuthProvider.select((_) => _.codeSent),
                  );
                  if (codeSent) {
                    return SmsCodeView();
                  }
                  return const PhoneNumberView();
                },
              ),
              NumericKeyboard(
                onValue: (text) {
                  phoneAuthProvider.read.onNumericKeyboard(text);
                },
                onDelete: () {
                  phoneAuthProvider.read.onNumericKeyboardDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
