import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/ui/global_controllers/session_controller.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/custom_input_field.dart';
import 'package:flutter_firebase_auth/app/ui/pages/register/utils/send_register_form.dart';
import 'package:flutter_firebase_auth/app/utils/email_validator.dart';
import 'package:flutter_firebase_auth/app/utils/name_validator.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/state.dart';

import 'controller/register_controller.dart';
import 'controller/register_state.dart';

final registerProvider = StateProvider<RegisterController, RegisterState>(
  (_) => RegisterController(sessionProvider.read),
);

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderListener<RegisterController>(
      provider: registerProvider,
      builder: (_, controller) {
        return Scaffold(
          appBar: AppBar(),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Form(
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    CustomInputField(
                      label: "Name",
                      onChanged: controller.onNameChanged,
                      validator: (text) {
                        return isValidName(text!) ? null : "invalid name";
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomInputField(
                      label: "Last Name",
                      onChanged: controller.onLastNameChanged,
                      validator: (text) {
                        return isValidName(text!) ? null : "invalid last name";
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomInputField(
                      label: "E-mail",
                      inputType: TextInputType.emailAddress,
                      onChanged: controller.onEmailChanged,
                      validator: (text) {
                        return isValidEmail(text!) ? null : "invalid email";
                      },
                    ),
                    const SizedBox(height: 15),
                    CustomInputField(
                      label: "Password",
                      onChanged: controller.onPasswordChanged,
                      isPassword: true,
                      validator: (text) {
                        if (text!.trim().length >= 6) {
                          return null;
                        }
                        return "invalid password";
                      },
                    ),
                    const SizedBox(height: 15),
                    Consumer(
                      builder: (_, watch, __) {
                        watch(
                          registerProvider.select(
                            (_) => _.password,
                          ),
                        );
                        return CustomInputField(
                          label: "Verification Password",
                          onChanged: controller.onVPasswordChanged,
                          isPassword: true,
                          validator: (text) {
                            if (controller.state.password != text) {
                              return "password don't match";
                            }
                            if (text!.trim().length >= 6) {
                              return null;
                            }
                            return "invalid password";
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      child: const Text("REGISTER"),
                      onPressed: () => sendRegisterForm(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
