import 'package:flutter/material.dart';

class SwipeDownPanel extends StatefulWidget {
  final bool isOpen;
  final upperBound;
  final lowerBound;
  final Widget body;
  final Widget backdrop;
  final Duration duration;
  final Color color;
  final Color backdropColor;

  SwipeDownPanel({
    Key key,
    this.body,
    this.color,
    this.backdrop,
    this.backdropColor,
    this.upperBound,
    this.lowerBound,
    this.isOpen = false,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _SwipeDownPanelState createState() => _SwipeDownPanelState();
}

class _SwipeDownPanelState extends State<SwipeDownPanel>
    with TickerProviderStateMixin {
  AnimationController _ac;
  Animation<double> _an;
  Animation<RelativeRect> rectAnimation;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      value: widget.isOpen ? 1.0 : 0.0,
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {});
      });

    _an = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(_ac);

    rectAnimation = new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_ac);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        widget.backdrop != null
            ? PositionedTransition(
                rect: rectAnimation,
                child: ScaleTransition(
                  scale: _an,
                  child: Opacity(
                    child: GestureDetector(
                      onTap: () {
                        _ac.reverse();
                      },
                      child: Container(
                        height: sizeHeight,
                        width: sizeWidth,
                        child: widget.backdrop,
                        color: widget.backdropColor??Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    opacity: _ac.value,
                  ),
                ),
              )
            : Container(),
        widget.body != null
            ? Positioned(
                top: _ac.value *
                        (sizeHeight - widget.lowerBound - widget.upperBound) +
                    widget.upperBound,
                height: sizeHeight - widget.upperBound,
                width: sizeWidth,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    _ac.value += details.primaryDelta / sizeHeight;
                  },
                  onVerticalDragEnd: (details) {
                    double minFlingVelocity = 365.0;

                    //let the current animation finish before starting a new one
                    if (_ac.isAnimating) return;

                    //check if the velocity is sufficient to constitute fling
                    if (details.velocity.pixelsPerSecond.dy.abs() >=
                        minFlingVelocity) {
                      double visualVelocity =
                          details.velocity.pixelsPerSecond.dy / sizeHeight;

                      _ac.fling(velocity: visualVelocity);

                      return;
                    }

                    // check if the controller is already halfway there
                    _ac.fling(velocity: _ac.value > 0.5 ? 1.0 : -1.0);
                  },
                  child: Material(
                    elevation: 16,
                    child: widget.body,
                    color: widget.color??Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}