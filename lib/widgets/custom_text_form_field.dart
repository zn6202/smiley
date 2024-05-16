import 'package:flutter/material.dart';
import '../core/app_export.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
      {Key? key,
      this.alignment,
      this.width,
      this.scrollPadding,
      this.controller,
      this.focusNode,
      this.autofocus = false,
      this.textStyle,
      this.obscureText = false,
      this.textInputAction = TextInputAction.next,
      this.textInputType = TextInputType.text,
      this.maxLines,
      this.hintText,
      this.hintStyle,
      this.prefix,
      this.prefixConstraints,
      this.suffix,
      this.suffixConstraints,
      this.contentPadding,
      this.borderDecoration,
      this.fillColor,
      this.filled = true,
      this.validator})
      : super(
          key: key,
        );

  final Alignment? alignment; // 對齊方式
  final double? width; // 寬度
  final TextEditingController? scrollPadding; // 滾動填充
  final TextEditingController? controller; // 控制器
  final FocusNode? focusNode; // 焦點節點
  final bool? autofocus; // 自動獲得焦點
  final TextStyle? textStyle; // 文本樣式
  final bool? obscureText; // 是否隱藏文本
  final TextInputAction? textInputAction; // 文本輸入操作
  final TextInputType? textInputType; // 文本輸入類型
  final int? maxLines; // 最大行數
  final String? hintText; // 提示文本
  final TextStyle? hintStyle; // 提示文本樣式
  final Widget? prefix; // 前綴圖標
  final BoxConstraints? prefixConstraints; // 前綴圖標約束
  final Widget? suffix; // 後綴圖標
  final BoxConstraints? suffixConstraints; // 後綴圖標約束
  final EdgeInsets? contentPadding; // 內容填充
  final InputBorder? borderDecoration; // 邊框裝飾
  final Color? fillColor; // 填充顏色
  final bool? filled; // 是否填充
  final FormFieldValidator<String>? validator; // 驗證器

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: textFormFieldWidget(context))
        : textFormFieldWidget(context);
  }

  // 構建文本輸入框的主要方法
  Widget textFormFieldWidget(BuildContext context) => SizedBox(
        width: width ?? double.maxFinite, // 設定寬度，預設為最大可用寬度
        child: TextFormField(
          scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom), // 根據鍵盤調整滾動填充
          controller: controller, // 設定控制器
          focusNode: focusNode, // 設定焦點節點
          onTapOutside: (event) {
            if (focusNode != null) {
              focusNode?.unfocus(); // 取消焦點
            } else {
              FocusManager.instance.primaryFocus?.unfocus(); // 取消主焦點
            }
          },
          autofocus: autofocus!, // 是否自動獲得焦點
          style: textStyle ?? theme.textTheme.titleMedium, // 設定文本樣式
          obscureText: obscureText!, // 是否隱藏文本
          textInputAction: textInputAction, // 設定文本輸入操作
          keyboardType: textInputType, // 設定文本輸入類型
          maxLines: maxLines ?? 1, // 設定最大行數，預設為1
          decoration: decoration, // 設定裝飾
          validator: validator, // 設定驗證器
        ),
      );

  // 獲取輸入框裝飾的方法
  InputDecoration get decoration => InputDecoration(
        hintText: hintText ?? "", // 提示文本
        hintStyle: hintStyle ?? theme.textTheme.titleMedium, // 提示文本樣式
        prefixIcon: prefix, // 前綴圖標
        prefixIconConstraints: prefixConstraints, // 前綴圖標約束
        suffixIcon: suffix, // 後綴圖標
        suffixIconConstraints: suffixConstraints, // 後綴圖標約束
        isDense: true, // 是否緊湊
        contentPadding: contentPadding ??
            EdgeInsets.only(
              top: 11.v,
              right: 11.h,
              bottom: 11.v,
            ), // 內容填充
        fillColor: fillColor ?? appTheme.whiteA700, // 填充顏色
        filled: filled, // 是否填充
        border: borderDecoration ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.h), // 邊框圓角
              borderSide: BorderSide.none, // 邊框樣式
            ),
        enabledBorder: borderDecoration ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.h), // 邊框圓角
              borderSide: BorderSide.none, // 邊框樣式
            ),
        focusedBorder: borderDecoration ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.h), // 邊框圓角
              borderSide: BorderSide.none, // 邊框樣式
            ),
      );
}
