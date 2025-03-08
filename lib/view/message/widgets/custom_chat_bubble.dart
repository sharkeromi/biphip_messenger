

import 'package:biphip_messenger/utils/constants/imports.dart';

class CustomBubbleNormal extends StatelessWidget {
  const CustomBubbleNormal({
    Key? key,
    required this.text,
    this.constraints,
    this.bubbleRadius = 16,
    this.isSender = true,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    this.userImage,
  }) : super(key: key);

  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final String text;
  final String? userImage;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final BoxConstraints? constraints;

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          if (!isSender)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipOval(
                  child: Container(
                    height: h24,
                    width: h24,
                    decoration: const BoxDecoration(
                      color: cBlackColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      userImage ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        BipHip.user,
                        size: kIconSize14,
                        color: cIconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          isSender
              ? Expanded(
                  child: SizedBox(
                    width: 5,
                  ),
                )
              : Container(),
          Container(
            color: Colors.transparent,
            constraints: constraints ?? BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(bubbleRadius),
                    topRight: Radius.circular(bubbleRadius),
                    bottomLeft: Radius.circular(tail
                        ? isSender
                            ? bubbleRadius
                            : 0
                        : 16),
                    bottomRight: Radius.circular(tail
                        ? isSender
                            ? 0
                            : bubbleRadius
                        : 16),
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: stateTick ? EdgeInsets.fromLTRB(12, 6, 28, 6) : EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: Text(
                        text,
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    stateIcon != null && stateTick
                        ? Positioned(
                            bottom: 4,
                            right: 6,
                            child: stateIcon,
                          )
                        : SizedBox(
                            width: 1,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
