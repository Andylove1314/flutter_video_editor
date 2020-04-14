
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const _slideHeight = 60.0;

///视频frameshow(滚动帧列表),目前不完善
class VideoEditFrameShowScroll extends StatefulWidget {
  double cuteVideoSeconds;
  double allVideoSeconds;

  VideoEditFrameShowScroll(
      {this.cuteVideoSeconds = 5, this.allVideoSeconds = 11});

  @override
  State<StatefulWidget> createState() {
    return _VideoEditFrameShowScrollState();
  }
}

class _VideoEditFrameShowScrollState extends State<VideoEditFrameShowScroll> {
  ///视频时间起点
  double _currentStartTime;

  ///视频时间止点
  double _currentEndTime;

  ///时间块儿宽度
  double _slideWidth = 45.0;

  ///帧宽度
  double _frameWidth = 15.0;

  List<String> _frames = [];

  GlobalKey _slideKey = GlobalKey();
  GlobalKey _frameKey = GlobalKey();

  double _slideX = 0.0;

  double _scrollOffsetx = 0.0;

  @override
  void initState() {
    _refreshStartEndSeconds(0.0);
    _getFrames(30);
    super.initState();
  }

  ///刷新起止时间
  void _refreshStartEndSeconds(double start) {
    _currentStartTime = start;
    _currentEndTime = _currentStartTime + widget.cuteVideoSeconds;
    print('起止时间：\nstart:$_currentStartTime\nend:$_currentEndTime');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: <Widget>[
          ///帧列表
          NotificationListener<ScrollNotification>(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: ClampingScrollPhysics(),
              child: Row(
                key: _frameKey,
                children: _frames.map((item) {
                  return Image.asset(
                    '$item',
                    width: _frameWidth,
                    height: _slideHeight,
                    fit: BoxFit.fill,
                  );
                }).toList(),
              ),
            ),
            onNotification: (scroll) {


              _scrollOffsetx = scroll.metrics.pixels;
              print('滑动距离:$_scrollOffsetx');
              print('帧列表总长度:${_frameKey.currentContext.size.width}');


              RenderBox slideBox = _slideKey.currentContext.findRenderObject();
              Offset slideOffset = slideBox.localToGlobal(Offset.zero);
              print('时间块位置 $slideOffset');
              RenderBox frameBox = _frameKey.currentContext.findRenderObject();
              Offset frameOffset = frameBox.localToGlobal(Offset.zero);
              print('帧列表位置 $frameOffset');

              double sigam = widget.allVideoSeconds/_frameKey.currentContext.size.width;
              double start = double.parse((sigam*(slideOffset.dx - frameOffset.dx)).toStringAsFixed(1));

              setState(() {
                _refreshStartEndSeconds(start);
              });

              return false;
            },
          ),

          ///时间截取滑块
          GestureDetector(
            onHorizontalDragUpdate: dragEvent,
            child: Transform.translate(
              offset: Offset(_slideX, 0),
              child: Container(
                alignment: Alignment.topLeft,
                child: Container(
                  key: _slideKey,
                  width: _slideWidth,
                  height: _slideHeight,
                  alignment: Alignment.center,
                  color: Color(0xaa008FFF),
                ),
              ),
            ),
          )
        ],
      ),
      height: _slideHeight,
    );
  }

  ///滑块拖拽事件
  void dragEvent(DragUpdateDetails details) {

    RenderBox slideBox = _slideKey.currentContext.findRenderObject();
    Offset slideOffset = slideBox.localToGlobal(Offset.zero);
    print('时间块位置 $slideOffset');
    RenderBox frameBox = _frameKey.currentContext.findRenderObject();
    Offset frameOffset = frameBox.localToGlobal(Offset.zero);
    print('帧列表位置 $frameOffset');

    //  获得自定义Widget的大小，用来计算Widget的中心锚点
    _slideX =
        details.globalPosition.dx - _slideKey.currentContext.size.width / 2;


    double sigam = widget.allVideoSeconds/_frameKey.currentContext.size.width;
    double start = double.parse((sigam*(slideOffset.dx - frameOffset.dx)).toStringAsFixed(1));

    setState(() {
      _refreshStartEndSeconds(start);
    });
  }

  ///获取视频帧展示
  void _getFrames(int count) {
    Future.delayed(Duration(milliseconds: 1000), () {
      for (int i = 0; i < count; i++) {
        _frames.add('images/home_guide_1.jpg');
      }
      setState(() {});
    });
  }
}
