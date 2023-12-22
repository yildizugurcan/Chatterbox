import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final double radius;
  final double yukseklik;
  final Widget? buttonIcon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    Key? key,
    required this.buttonText,
    this.buttonColor = Colors.purple,
    this.textColor = Colors.white,
    this.radius = 16,
    this.yukseklik = 40,
    this.buttonIcon,
    required this.onPressed,
  })  : assert(buttonText != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: yukseklik,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(radius)))),
            backgroundColor: MaterialStatePropertyAll(buttonColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (buttonIcon != null) ...[
                buttonIcon!,
                Text(
                  buttonText,
                  style: TextStyle(color: textColor),
                ),
                Opacity(opacity: 0, child: buttonIcon),
              ],
              if (buttonIcon == null) ...[
                Container(),
                Text(
                  buttonText,
                  style: TextStyle(color: textColor),
                ),
                Container(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
