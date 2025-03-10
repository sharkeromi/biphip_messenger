

import 'package:biphip_messenger/controllers/messenger/messenger_controller.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:biphip_messenger/utils/constants/strings.dart';
import 'package:biphip_messenger/widgets/common/textfields/custom_textfield.dart';

class ChatTextField extends StatelessWidget {
  ChatTextField({super.key});
  final MessengerController messengerController = Get.find<MessengerController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          color: cWhiteColor,
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!messengerController.isMessageTextFieldFocused.value)
                  Padding(
                    padding: const EdgeInsets.only(right: k12Padding, bottom: 14),
                    child: Icon(
                      BipHip.voiceFill,
                      color: cPrimaryColor,
                    ),
                  ),
                if (!messengerController.isMessageTextFieldFocused.value)
                  Padding(
                    padding: const EdgeInsets.only(right: k12Padding, bottom: 14),
                    child: Icon(
                      BipHip.imageFile,
                      color: cPrimaryColor,
                    ),
                  ),
                if (!messengerController.isMessageTextFieldFocused.value)
                  Padding(
                    padding: const EdgeInsets.only(right: k12Padding, bottom: 14),
                    child: Icon(
                      BipHip.sticker,
                      color: cPrimaryColor,
                    ),
                  ),
                if (!messengerController.isMessageTextFieldFocused.value)
                  Padding(
                    padding: const EdgeInsets.only(right: k12Padding, bottom: 14),
                    child: Icon(
                      BipHip.gif,
                      color: cPrimaryColor,
                    ),
                  ),
                if (messengerController.isMessageTextFieldFocused.value)
                  Padding(
                    padding: const EdgeInsets.only(right: k8Padding, bottom: 10),
                    child: SizedBox(
                      width: 25,
                      child: InkWell(
                        onTap: () {
                          messengerController.isMessageTextFieldFocused.value = false;
                        },
                        child: Icon(
                          BipHip.rightArrow,
                          color: cPrimaryColor,
                          size: kIconSize35,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CustomModifiedTextField(
                              maxLines: 5,
                              minLines: 1,
                              inputAction: TextInputAction.newline,
                              inputType: TextInputType.multiline,
                              focusNode: messengerController.messageFocusNode,
                              controller: messengerController.messageTextEditingController,
                              suffixIconColor: cPrimaryColor,
                              borderRadius: h18,
                              hint: ksMessage.tr,
                              contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: k8Padding),
                              onChanged: (v) {
                                messengerController.isMessageTextFieldFocused.value = true;
                                messengerController.checkCanSendMessage();
                              },
                            ),
                            Positioned(
                                bottom: 12,
                                right: 4,
                                child: Icon(
                                  BipHip.emoji,
                                  color: cPrimaryColor,
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (!messengerController.isSendEnabled.value)
                  Padding(
                    padding: const EdgeInsets.only(left: k8Padding, bottom: 14),
                    child: Icon(
                      BipHip.love,
                      color: cRedColor,
                    ),
                  ),
                if (messengerController.isSendEnabled.value)
                  Padding(
                    padding: const EdgeInsets.only(left: k8Padding, bottom: 14),
                    child: InkWell(
                      onTap: messengerController.isSendEnabled.value
                          ? () {
                              messengerController.sendMessage(
                                  messengerController.messageTextEditingController.text.trim(), messengerController.targetDataChannel!);
                            }
                          : null,
                      child: const Icon(
                        BipHip.sendNew,
                        color: cPrimaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
