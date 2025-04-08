import 'package:biphip_messenger/utils/constants/imports.dart';

class CustomChoiceChips extends StatelessWidget {
  const CustomChoiceChips({super.key, required this.label, required this.isSelected, this.onSelected, this.borderRadius});

  final String label;
  final bool isSelected;
  final Function(bool)? onSelected;
  final BorderRadius? borderRadius;
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: h8),
        child: Text(
          label,
          style: regular14TextStyle(isSelected ? cPrimaryColor : cBlackColor),
        ),
      ),
      selectedColor: cPrimaryTint3Color,
      disabledColor: cWhiteColor,
      onSelected: onSelected,
      backgroundColor: cWhiteColor,
      showCheckmark: false,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? k100CircularBorderRadius,
      ),
      side: BorderSide(
        color: isSelected ? cPrimaryColor : cLineColor,
      ),
      selected: isSelected,
    );
  }
}
