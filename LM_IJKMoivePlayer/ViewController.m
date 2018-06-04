//
//  ViewController.m
//  LM_IJKMoivePlayer
//
//  Created by Leesim on 17/2/22.
//  Copyright © 2017年 LiMing. All rights reserved.
//

#import "ViewController.h"
#import "LMIJKVideoPlayerView.h"

@interface ViewController ()
/** 视频播放视图 */
@property (nonatomic, strong) LMIJKVideoPlayerView *playerView;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerView];
    
    //测试地址
    //rtmp 直播 香港电视台测试地址 rtmp://live.hkstv.hk.lxdns.com/live/hks
    //录播 播放流
    //http://qimage.owhat.cn/test/master/media/1510731201386.mp4
    
    self.playerView.videoUrl = @"http://qimage.owhat.cn/test/master/media/1510731201386.mp4";
 
}


//在销毁控制器时一定要调用销毁方法 用来销毁监听
//一定要在销毁控制器之后 进行销毁视频播放器
- (void)dealloc{
    [self.playerView deallocPlayer];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - lazy load

-(LMIJKVideoPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[LMIJKVideoPlayerView alloc]initWithFrame:self.view.frame];
    }
    return _playerView;
}





@end
