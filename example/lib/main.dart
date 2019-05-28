import 'package:flutter/widgets.dart';
import 'package:bidirectional_scrollview/bidirectional_scrollview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BidirectionalScrollView(
        maxOffsetDelta: 16,
        child: Image.asset(
          'assets/pic_map.jpg',
          width: 1024,
          height: 1024,
        ),
      ),
    );
  }
}
