import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class AnimatedLiquidCircularProgressIndicator extends StatefulWidget {
  double? normalisedValue;
  double? displayValue;
  AnimatedLiquidCircularProgressIndicator({this.normalisedValue, this.displayValue});

  @override
  State<StatefulWidget> createState() =>
      _AnimatedLiquidCircularProgressIndicatorState();
}

class _AnimatedLiquidCircularProgressIndicatorState
    extends State<AnimatedLiquidCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  // double waterPortionCovered;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      value: this.widget.normalisedValue,
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animationController?.addListener(() => setState(() {
          _animationController!.value == this.widget.normalisedValue?.toDouble()
              ? _animationController!.stop()
              : _animationController!.repeat();
        }));
    //_animationController.repeat();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
  // _AnimatedLiquidCircularProgressIndicatorState({this.waterPortionCovered, context, });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100.0,
        height: 100.0,
        child: LiquidCircularProgressIndicator(
          borderColor: greyColor,
          borderWidth: 1.0,
          direction: Axis.vertical,
          value: _animationController!.value,
          //value: this.widget.value.TODOuble(),
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(
            secondaryColor,
          ),
          center: Text(
            "${this.widget.displayValue!.toStringAsFixed(0)}",
            style: TextStyle(
              color: blackColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
