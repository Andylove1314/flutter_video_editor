import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_editor/video_edit_frame_show.dart';
import 'package:flutter_video_editor/video_player.dart';
import 'package:flutter_video_editor/ffmpeg_utils.dart';
import 'package:image_picker/image_picker.dart';

///截取时长
const _cutDuration = 2.5;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    initFFmpegWrap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }

}

///home
class _HomeState extends State<Home> {

  File video;
  double startTime = 0.0;

  ///为了精确，单位毫秒
  var allVideoDuration;

  ///播放控制器
  ChewieController playController;

  @override
  void dispose() {
    clearCuteVideoCache();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin video editor'),
      ),
      body: Column(
        children: <Widget>[
          ///选择视频
          Container(
            width: double.infinity,
            height: 80,
            child: RaisedButton(
              onPressed: () async {
                File file =
                await ImagePicker.pickVideo(source: ImageSource.gallery);
                print('原视频路径: ${file?.path}');
                if (file == null) {
                  return;
                }

                int videoTotal = await getVideoDuration(file.path);
                setState(() {
                  allVideoDuration = videoTotal;
                  print('视频总时长毫秒：$allVideoDuration');
                  video = file;
                });
              },
              child: Center(
                child: Text('choose video'),
              ),
            ),
          ),

          ///video
          Expanded(
            child: (video == null)
                ? Container(
              color: Colors.green,
              child: Center(
                child: Text('原始视频'),
              ),
            )
                : Container(
              child: AndyloveVideoPlayer(
                video,
                start: startTime,
                duration: _cutDuration,
                callBack: (player){
                  playController = player;
                },
              ),
              color: Color(0xff252525),
            ),
            flex: 1,
          ),

          ///截取块
          (video == null)
              ? SizedBox(
            width: 0,
            height: 0,
          )
              : VideoEditFrameShow(
            videoPath: video.path,
            cuteVideoSeconds: (_cutDuration > (allVideoDuration / 1000))
                ? (allVideoDuration / 1000)
                : _cutDuration,
            allVideoSeconds: allVideoDuration / 1000,
            editListener: (start, end) {
              setState(() {
                this.startTime = start;
              });
            },
          ),

          ///剪切视频
          Container(
            width: double.infinity,
            height: 80,
            child: RaisedButton(
              onPressed: () async {

                ///开始剪切时暂停视频播放
                playController?.pause();

                ///loading
                showCupertinoDialog(
                    context: context,
                    builder: (ctx) {
                      return Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _getLoadding(),
                            SizedBox(
                              height: 10,
                            ),
                            Text('cuting...'),
                          ],
                        ),
                        width: 100,
                        height: 100,
                        alignment: Alignment.center,
                      );
                    });

                String cutePath =
                await cuteVideo(video.path, startTime, _cutDuration);

                Navigator.pop(context);

                if(cutePath == null){
                  print('剪切失败');
                  return;
                }
                print('剪切后的视频路径：$cutePath');
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CutVideoPlayer(File(cutePath));
                }));
              },
              child: Center(
                child: Text('cute video'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


///播放剪辑后的视频
class CutVideoPlayer extends StatelessWidget {
  File video;

  CutVideoPlayer(this.video);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('cutVideo'),
      ),
      body: Container(child: AndyloveVideoPlayer(
        video,
        autoPlay: true,
      ),color: Color(0xff252525),),
    );
  }
}
