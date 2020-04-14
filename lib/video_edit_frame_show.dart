import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ffmpeg_utils.dart';

const _frameHeight = 55.0;

///时间块儿宽度
const _slideWidth = 75.0;
const _slideHeight = 61.0;

const _unSelectedOverlayColor = Color(0x80000000);

///视频frameshow(不滚动帧列表)
class VideoEditFrameShow extends StatefulWidget {
  String videoPath;
  double cuteVideoSeconds;
  double allVideoSeconds;

  Function(double start, double end) editListener;

  VideoEditFrameShow(
      {this.videoPath,
      this.cuteVideoSeconds,
      this.allVideoSeconds,
      this.editListener});

  @override
  State<StatefulWidget> createState() {
    return _VideoEditFrameShowState();
  }
}

class _VideoEditFrameShowState extends State<VideoEditFrameShow> {
  ///视频时间起点
  double _currentStartTime;

  ///视频时间止点
  double _currentEndTime;

  ///滑块总进度
  double _slideMax;

  ///帧宽度
  double _frameWidth = 25.0;

  ///时间块儿左边距
  double _slideLeft;

  List<String> _frames = [];

  @override
  void initState() {
    _slideMax = widget.allVideoSeconds - widget.cuteVideoSeconds;
    _refreshStartEndSeconds(0.0);
    _getFrames();
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

    _slideLeft = _currentStartTime *
        ((MediaQuery.of(context).size.width -
            _slideWidth) /
            (widget.allVideoSeconds - widget.cuteVideoSeconds));

    ///左蒙版宽度
    double popLeftWidth = _slideLeft - 22.5;
    if(popLeftWidth < 0){
      popLeftWidth = 0;
    }
    ///右蒙版宽度
    double popRightWidth = MediaQuery.of(context).size.width - _slideLeft - _slideWidth - 22.5;
    if(popRightWidth < 0){
      popRightWidth = 0;
    }

    ///如果所剪切视频与视频总时长等长，则不需要剪切，也不需要选帧
    return (widget.cuteVideoSeconds == widget.allVideoSeconds)?SizedBox(height: 0,):SizedBox(
      child: _frames.length > 0
          ? Stack(
        children: <Widget>[
          ///视频帧列表
          Align(child: Container(
            height: _frameHeight,
            child: Row(
              children: _frames.map((item) {
                return Image.file(
                  File('$item'),
                  width: _frameWidth,
                  height: _frameHeight,
                  fit: BoxFit.fill,
                );
              }).toList(),
            ),
            margin: EdgeInsets.only(left:7.5,right: 7.5,bottom: 7.5),
            padding: EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                top: 5.0,
                bottom: 5.0),
            decoration: BoxDecoration(
                color: Color(0xff333333),
                borderRadius: BorderRadius.all(
                    Radius.circular(5.0))),
          ),alignment: Alignment.bottomCenter,),

          ///视频进度
          SliderTheme(
              data: SliderThemeData(
                trackHeight: 0.0,
                overlayColor: Colors.transparent,
                thumbColor: Colors.transparent,
              ),
              child: Slider(
                  max: _slideMax,
                  value: _currentStartTime,
                  onChanged: (_currentValue) {
                    setState(() {
                      _refreshStartEndSeconds(
                          double.parse(_currentValue.toStringAsFixed(1)));
                    });
                    if (widget.editListener != null) {
                      widget.editListener(_currentStartTime, _currentEndTime);
                    }
                  })),

          ///时间切块
          IgnorePointer(
            child: Stack(children: <Widget>[

              ///半透明-左侧
              Align(child: Container(color: _unSelectedOverlayColor,width: popLeftWidth,margin: EdgeInsets.only(top: 17.0,bottom: 12.5,left: 22.5)),alignment: Alignment.centerLeft),

              ///滑块(随意改)
              Container(
                alignment: Alignment.center,
                width: _slideWidth,
                height: _slideHeight + 20.0,
                margin: EdgeInsets.only(left: _slideLeft,bottom: 5.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(child: Container(
                      width: _slideWidth,
                      height: _slideHeight,
                      color:Color(0xaa40daee)
                    ),
                    ),
                    Text(
                      '${widget.cuteVideoSeconds} Seconds',
                      style: TextStyle(
                          color: Color(0xff000000),
                          fontSize: 8.0),
                    )
                  ],
                ),
              ),

              ///半透明-右侧
              Align(child: Container(margin: EdgeInsets.only(top: 17.0,bottom: 12.5,right: 22.5),color: _unSelectedOverlayColor,width: popRightWidth,),alignment: Alignment.centerRight,)

            ],),
            ignoring: true,
          )
        ],
      )
          : _getLoadding(),
      height: _frameHeight + 20.0,
    );
  }

  Widget _getLoadding() {
    return new Center(
        child: (Platform.isIOS)?new CupertinoActivityIndicator():CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffF04B42)),
        ));
  }

  ///获取视频帧展示
  _getFrames() {

    if(widget.allVideoSeconds == widget.cuteVideoSeconds){
      return;
    }

    Future.delayed(Duration(milliseconds: 300), () async {
      int count = ((MediaQuery.of(context).size.width - 45.0)/ _frameWidth).ceil();
      getVideoFrames(widget.videoPath, widget.allVideoSeconds, count, (items) {
        setState(() {
          _frames = items;
        });
      });
    });
  }

}
