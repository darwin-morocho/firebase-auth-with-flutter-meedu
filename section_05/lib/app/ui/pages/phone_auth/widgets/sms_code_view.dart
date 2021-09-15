import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/rounded_button.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/phone_auth_page.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/utils/request_sms_code.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/utils/verify_sms_code.dart';
import 'package:flutter_meedu/rx.dart';
import 'package:flutter_meedu/state.dart';

class SmsCodeView extends StatelessWidget {
  SmsCodeView({Key? key}) : super(key: key);

  final controller = phoneAuthProvider.read;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final phone = state.country.dialCode + state.phoneNumber;
    return Column(
      children: [
        Text("Code is sent to $phone"),
        const SizedBox(height: 20),
        Consumer(
          builder: (_, ref, resendWidget) {
            final smsCode = ref.select(
              phoneAuthProvider.select((_) => _.smsCode),
            );
            return Column(
              children: [
                Text(
                  smsCode.isEmpty ? "******" : smsCode,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: smsCode.isEmpty ? Colors.black38 : Colors.black,
                  ),
                ),
                resendWidget!,
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: RoundedButton(
                    text: "Verify",
                    onPressed: smsCode.length == 6
                        ? () {
                            verifySmsCode(context);
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
          child: RxBuilder((_) {
            final time = controller.requestAgainTime;
            if (time > 0) {
              return Text("wait $time to send again");
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't recieve code?",
                  style: TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () => requestSmsCode(context),
                  child: const Text(
                    "Request again",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            );
          }),
        )
      ],
    );
  }
}
