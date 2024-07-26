import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class AppbarLeadingImage extends StatelessWidget {
  final String? imagePath;
  final EdgeInsetsGeometry? margin;
  final Function? onTap;

  AppbarLeadingImage({Key? key, this.imagePath, this.margin, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: CustomImageView(
          imagePath: imagePath!,
          height: 10.v,
          width: 9.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
