
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

FlutterFFmpeg _flutterFFmpeg;
FlutterFFprobe _probe;
String        _path;

///初始化ffmpeg
void initFFmpegWrap() async{
  if(_flutterFFmpeg == null){
    _flutterFFmpeg = new FlutterFFmpeg();
    _probe = new FlutterFFprobe();
  }else{
    return;
  }
  try{
    Directory extDir = await getApplicationDocumentsDirectory();
    String dirPath = '${extDir.path}/Pictures/videoedit';
    Directory sonDir = Directory(dirPath);
    bool exist = await sonDir.exists();
    if (!exist) {
      await sonDir.create(recursive: true);
    }
    _path = sonDir.path;
  }catch(e){
    print('ffmpeg create dir:$e');
  }
}

///获取视频时长（毫秒）
Future<int> getVideoDuration(String pathInput) async{
  if(_flutterFFmpeg == null){
    print('Please init FFmpegWrap first.');
    return null;
  }
  var videoInfo = await _probe.getMediaInformation(pathInput);
  return videoInfo['duration'];
}

///获取视频缩略图
Future<String> getVideoFrame(pathInput, {imgSize='352x240', quality=100}) async{
  var now = DateTime.now();
  var timeStamp = now.millisecondsSinceEpoch;
  String pathOutput = '$_path/thumbnail$timeStamp.jpg';
  quality = (100 - quality)*0.01*30;
  quality = (quality < 1)? 1:quality;
  int rc = await _flutterFFmpeg.execute('-i $pathInput -y -frames:v 1 -f image2 -s $imgSize -q:v $quality $pathOutput ');
  if(rc == 0){
    return pathOutput;
  }else{
    return '-1';
  }
}

///剪切视频（规则可以通过命令行自定义）
Future<String> cuteVideo( String pathInput, var startSec, var dur) async {
  if(_flutterFFmpeg == null){
    print('Please init FFmpegWrap first.');
    return null;
  }
  //-ss 00:00:05
  if(startSec < 0)startSec = 0;
  if(dur< 1)dur = 1;
  var tempStrAry = pathInput.split('.');
  var fileType = tempStrAry[tempStrAry.length-1];
  String pathOutput = '$_path/curVideo.$fileType';
//  await _flutterFFmpeg.execute("-i $pathInput -y -ss $startSec -t $dur -codec copy  $pathOutput");
  await _flutterFFmpeg.execute(" -ss $startSec -i $pathInput -y  -codec copy -t $dur $pathOutput");

  return pathOutput;

}

///获取视频帧数组（规则可以通过命令行自定义）
void getVideoFrames(pathInput, totalTime, count, callback, {imgSize}){
  if(_flutterFFmpeg == null){
    print('Please init FFmpegWrap first.');
    return;
  }
  if(count < 5)count = 5;
  String size = '50x80';
  if(imgSize != null)size = imgSize;
  var now = DateTime.now();
  var timeStamp = now.millisecondsSinceEpoch;
  String pathOutput = '$_path/${timeStamp}out%08d.jpg';
  _flutterFFmpeg.execute('-i $pathInput -y -f image2 -vf fps=fps=$count/$totalTime -s $size $pathOutput').then((rc){
    print("FFmpeg process exited with rc $rc");
    if(rc == 0){
      List<String> results = [];
      for(int i=1; i<= count; i++){
        String tempIndex = i.toString().padLeft(8, '0');
        results.add('$_path/${timeStamp}out$tempIndex.jpg');
      }
      callback(results);
    }else{
      callback([]);
    }
  });
}

///清除临时数据
void clearCuteVideoCache(){

  if(_path == null){
    return;
  }

  Directory dir = Directory(_path);
  List<FileSystemEntity> list = dir.listSync();
  for(int i=0; i<list.length; i++){
    list[i].delete();
  }
}