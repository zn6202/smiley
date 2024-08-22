import 'package:flutter/material.dart';
import 'browsePage.dart';

class FallingEmojiComment extends StatefulWidget {
  final int emojiId;
  final double screenHeight;
  final double horizontalPosition;

  const FallingEmojiComment({
    Key? key,
    required this.emojiId,
    required this.screenHeight,
    required this.horizontalPosition,
  }) : super(key: key);

  @override
  _FallingEmojiCommentState createState() => _FallingEmojiCommentState();
}

class _FallingEmojiCommentState extends State<FallingEmojiComment> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _animation = Tween<double>(begin: -50, end: widget.screenHeight).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.horizontalPosition,
      top: _animation.value,
      child: Image.asset(
        'assets/images/comments_${widget.emojiId}.png',
        width: 50,
        height: 50,
      ),
    );
  }
}