import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

///视频播放
class AndyloveVideoPlayer extends StatefulWidget {
  File video;
  double start;
  var duration;
  bool autoPlay;
  Function(ChewieController playController) callBack;

  AndyloveVideoPlayer(this.video,
      {this.start = 0, this.duration, this.autoPlay = false, this.callBack});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PictureVideoPlayerState();
  }
}

class _PictureVideoPlayerState extends State<AndyloveVideoPlayer> {
  VideoPlayerController _controller;
  ChewieController chewieController;

  Future<void> inited;

  ///自定义播放控制器
  Widget customControl;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.video)
      ..addListener(() {
        if (!mounted) {
          return;
        }

        if (widget.duration == null) {
          return;
        }

        if (_controller != null && _controller.value.initialized) {
          if (_controller.value.position.inMilliseconds >
              widget.start + widget.duration) {
//          print('重播时间开始：${widget.start}');
//          print('播放时间到：${_controller.value.position.inMilliseconds}');
            chewieController
                .seekTo(Duration(milliseconds: widget.start.toInt()));
          }
        }
      });
    inited = _controller.initialize();
    if (widget.autoPlay) {
      _controller.play();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    chewieController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    customControl = GestureDetector(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: !_controller.value.isPlaying
            ? Container(width: 50.0,height: 50.0,child: Text('Paused',style: TextStyle(color: Colors.red),),color: Colors.white,alignment: Alignment.center,)
            : SizedBox(
                width: 0,
                height: 0,
              ),
      ),
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            chewieController.pause();
          } else {
            chewieController.play();
          }
        });
      },
    );

    return Center(
        child: FutureBuilder(
            future: inited,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                chewieController = ChewieController(
                    videoPlayerController: _controller,
                    aspectRatio: _controller.value.aspectRatio,
                    autoPlay: false,
                    looping: true,
                    customControls: customControl,
                    startAt: Duration(milliseconds: widget.start.toInt()),
                    autoInitialize: true);
                if (widget.callBack != null) {
                  widget.callBack(chewieController);
                }
                return Chewie(
                  controller: chewieController,
                );
              }

              return _getLoadding();
            }));
  }

  Widget _getLoadding() {
    return new Center(
        child: (Platform.isIOS)
            ? new CupertinoActivityIndicator()
            : CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffF04B42)),
              ));
  }
}
