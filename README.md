# LM_IJKMoviePlayer

[中文详细介绍地址](https://www.jianshu.com/p/4d555d09d3e2)<br /> 

### 基本效果图
![效果图](https://upload-images.jianshu.io/upload_images/1197929-bdc7ea869c0c4541.gif?imageMogr2/auto-orient/strip)

Due to the limitation of recording screen, the actual experience on real device is much better the gif shown above.


### The project is based on the open source project of the  IJKPlayer, Adds some basic functions based on this <br /> 

1.Left of the screen brightness adjustment slide vertically<br /> 
2.The right screen slides up and down to adjust the volume<br /> 
3.Drag left and right to change the playback progress<br /> 
4.Horizontal and vertical screen switching<br /> 

### Support playback format <br /> 

1.Support rtmp/hls live streaming<br /> 
2.Video cloud url broadcast<br /> 


Due to IJKPlayer framework is relatively large, it is not uploaded into the project. Please click on the link below to extract it, unzip it and put it into the project.

[Click here to download the IJKPlayer that has already been framed](https://pan.baidu.com/s/1poiLkuDRN26KV-JkbHXSaQ)<br /> 

## Usage <br /> 

```objc
#import "LMIJKVideoPlayerView.h"

/** 视频播放视图 */
@property (nonatomic, strong) LMIJKVideoPlayerView *playerView;

-(LMIJKVideoPlayerView *)playerView{
if (!_playerView) {
_playerView = [[LMIJKVideoPlayerView alloc]initWithFrame:self.view.frame];
}
return _playerView;
}

```
```objc
- (void)viewDidLoad {
[super viewDidLoad];
[self.view addSubview:self.playerView];
//测试地址
//rtmp 直播 香港电视台测试地址 rtmp://live.hkstv.hk.lxdns.com/live/hks
//录播 播放流
//http://qimage.owhat.cn/test/master/media/1510731201386.mp4

self.playerView.videoUrl = @"http://qimage.owhat.cn/test/master/media/1510731201386.mp4";

}
```
When the controller is destroyed, remember to call the destroy method of the video player:

```objc
- (void)dealloc{
[self.playerView deallocPlayer];
}
```


