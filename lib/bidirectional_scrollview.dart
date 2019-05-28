import 'package:flutter/widgets.dart';

class BidirectionalScrollView extends StatefulWidget {
  BidirectionalScrollView({@required this.child, this.maxOffsetDelta, this.scrollListener});

  final Widget child;
  final double maxOffsetDelta;
  final ValueChanged<Offset> scrollListener;

  _BidirectionalScrollViewState _state;

  @override
  State<StatefulWidget> createState() => _state = _BidirectionalScrollViewState(child, maxOffsetDelta, scrollListener);

  // set x and y scroll offset of the overflowed widget
  set offset(Offset offset) {
    _state.offset = offset;
  }

  // x scroll offset of the overflowed widget
  double get x {
    return _state.x;
  }

  // x scroll offset of the overflowed widget
  double get y {
    return _state.y;
  }

  // height of the overflowed widget
  double get height {
    return _state.height;
  }

  // width of the overflowed widget
  double get width {
    return _state.width;
  }

  // height of the container that holds the overflowed widget
  double get containerHeight {
    return _state.containerHeight;
  }

  // width of the container that holds the overflowed widget
  double get containerWidth {
    return _state.containerWidth;
  }
}

class _BidirectionalScrollViewState extends State<BidirectionalScrollView> with SingleTickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _positionedKey = GlobalKey();

  Widget _child;
  double _maxOffsetDelta = 0.0;
  ValueChanged<Offset> _scrollListener;

  double xPos = 0.0;
  double yPos = 0.0;
  double xViewPos = 0.0;
  double yViewPos = 0.0;

  _BidirectionalScrollViewState(Widget child, double maxOffsetDelta, ValueChanged<Offset> scrollListener) {
    _child = child;
    if (maxOffsetDelta != null) {
      _maxOffsetDelta = maxOffsetDelta;
    }
    if (scrollListener != null) {
      _scrollListener = scrollListener;
    }
  }

  set offset(Offset offset) {
    setState(() {
      xViewPos = -offset.dx;
      yViewPos = -offset.dy;
    });
  }

  double get x {
    return -xViewPos;
  }

  double get y {
    return -yViewPos;
  }

  double get height {
    RenderBox renderBox = _positionedKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  double get width {
    RenderBox renderBox = _positionedKey.currentContext.findRenderObject();
    return renderBox.size.width;
  }

  double get containerHeight {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.height;
  }

  double get containerWidth {
    RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    return containerBox.size.width;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox referenceBox = context.findRenderObject();
    final position = referenceBox.globalToLocal(details.globalPosition);

    double dx = position.dx - xPos;
    double dy = position.dy - yPos;

    if (_maxOffsetDelta > 0.0) {
      if (dx > _maxOffsetDelta) dx = _maxOffsetDelta;
      if (dx < -_maxOffsetDelta) dx = -_maxOffsetDelta;
      if (dy > _maxOffsetDelta) dy = _maxOffsetDelta;
      if (dy < -_maxOffsetDelta) dy = -_maxOffsetDelta;
    }

    double newXPosition = xViewPos + dx;
    double newYPosition = yViewPos + dy;

    final RenderBox containerBox = _containerKey.currentContext.findRenderObject();
    final containerWidth = containerBox.size.width;
    final containerHeight = containerBox.size.height;

    if (newXPosition > 0.0 || width < containerWidth) {
      newXPosition = 0.0;
    } else if (-newXPosition + containerWidth > width) {
      newXPosition = containerWidth - width;
    }

    if (newYPosition > 0.0 || height < containerHeight) {
      newYPosition = 0.0;
    } else if (-newYPosition + containerHeight > height) {
      newYPosition = containerHeight - height;
    }

    setState(() {
      xViewPos = newXPosition;
      yViewPos = newYPosition;
    });

    xPos = position.dx;
    yPos = position.dy;

    _sendScrollValues();
  }

  void _handlePanDown(DragDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject();
    final Offset position = referenceBox.globalToLocal(details.globalPosition);

    xPos = position.dx;
    yPos = position.dy;
  }

  void _handlePanEnd(DragEndDetails details) {
    xPos = xViewPos;
    yPos = yViewPos;
  }

  void _sendScrollValues() {
    if (_scrollListener != null) {
      _scrollListener(Offset(-xViewPos, -yViewPos));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: _handlePanDown,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Container(
          key: _containerKey,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(key: _positionedKey, top: yViewPos, left: xViewPos, child: _child),
            ],
          )),
    );
  }
}
