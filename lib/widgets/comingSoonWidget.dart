import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

Widget ComingSoonWidget({
  Color? waveColor,
  Color? boxBackgroundColor,
  TextStyle? textStyle
}){
  return Center(
    child: FittedBox(
      fit: BoxFit.contain,
      child: DefaultTextStyle(
        style: textStyle!,
        child: AnimatedTextKit(
          isRepeatingAnimation: true,
          repeatForever: true,
          animatedTexts: [
            TypewriterAnimatedText('Coming Soon'),
            TypewriterAnimatedText('Pratishtha'),
            TypewriterAnimatedText('SAKEC'),
            TypewriterAnimatedText('Inspire.'),
            TypewriterAnimatedText('Innovate.'),
            TypewriterAnimatedText('Ignite.')
          ],
        ),
      ),
    ),
  );
}