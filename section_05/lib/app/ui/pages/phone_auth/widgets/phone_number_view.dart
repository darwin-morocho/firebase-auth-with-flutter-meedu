import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/country_picker/country_picker.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/rounded_button.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/phone_auth_page.dart';
import 'package:flutter_firebase_auth/app/ui/pages/phone_auth/utils/request_sms_code.dart';
import 'package:flutter_meedu/state.dart';

class PhoneNumberView extends StatelessWidget {
  const PhoneNumberView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, 10),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Enter your phone"),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final country = await showCountryPicker();
                        if (country != null) {
                          phoneAuthProvider.read.onCountryChanged(
                            country,
                          );
                        }
                      },
                      child: Consumer(builder: (_, ref, __) {
                        final dialCode = ref.select(
                          phoneAuthProvider.select((_) => _.country.dialCode),
                        );
                        return Text(
                          dialCode,
                          style: textStyle,
                        );
                      }),
                    ),
                    Expanded(
                      child: Consumer(builder: (_, ref, __) {
                        final phoneNumber = ref.select(
                          phoneAuthProvider.select((_) => _.phoneNumber),
                        );
                        return Text(
                          phoneNumber,
                          style: textStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 15),
          Consumer(
            builder: (_, ref, __) {
              final isValidNumber = ref.select(
                phoneAuthProvider.select((_) => _.isValidNumber),
              );
              return RoundedButton(
                text: "continue",
                onPressed: isValidNumber ? () => requestSmsCode(context) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
