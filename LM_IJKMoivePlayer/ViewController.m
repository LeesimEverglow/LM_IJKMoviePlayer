//
//  ViewController.m
//  LM_IJKMoivePlayer
//
//  Created by Leesim on 17/2/22.
//  Copyright © 2017年 LiMing. All rights reserved.
//

#import "ViewController.h"

#import "LMVideoPlayerView.h"
#import "XYVideoModel.h"

//屏幕的比例 小屏幕播放器占屏幕的比例
#define videoTempProgress 16/25

@interface ViewController ()<LMVideoPlayerViewDelegate>

{
    UIView *_headPlayerView;
}

/** 视频播放视图 */
@property (nonatomic, strong) LMVideoPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
//状态栏显示控制
- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}

//设置ui
- (void)setUI{

    // 创建盛放视频播放器的父视图 用于改变全屏和缩小
    _headPlayerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.width*videoTempProgress)];
    [self.view addSubview:_headPlayerView];

    
    //测试地址
    //rtmp 直播 香港电视台测试地址 rtmp://live.hkstv.hk.lxdns.com/live/hks
    //录播 播放流
    //http://hc.yinyuetai.com/uploads/videos/common/E49E014999C93F5A88EA01B2B48161CE.flv?sc=fc5276d37b6cd89c&br=775&vid=2178416&aid=2650&area=Other&vst=3
    
    //该模型可以随意设置  来传入你想自定义的内容
    XYVideoModel *model = [[XYVideoModel alloc]init];
    model.url = [NSURL URLWithString:@"http://hc.yinyuetai.com/uploads/videos/common/E49E014999C93F5A88EA01B2B48161CE.flv?sc=fc5276d37b6cd89c&br=775&vid=2178416&aid=2650&area=Other&vst=3"];
    model.name = @"测试标题测试标题测试标题";
    model.coverimg = @"coverimg.jpeg";
    
    // 创建视频播放控件
    self.playerView = [[LMVideoPlayerView alloc]initWithModel:model];
    self.playerView.delegate = self;
    [_headPlayerView addSubview:self.playerView];

}

#pragma mark XYVideoPlayerViewDelegate
//全屏按钮代理方法
- (void)fullScreenWithPlayerView:(LMVideoPlayerView *)videoPlayerView
{
    if (self.playerView.isRotate) {
        [UIView animateWithDuration:0.3 animations:^{
            _headPlayerView.transform = CGAffineTransformRotate(_headPlayerView.transform, M_PI_2);
            _headPlayerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            self.playerView.frame = _headPlayerView.bounds;
            
        }];
        
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            _headPlayerView.transform = CGAffineTransformIdentity;
            _headPlayerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*videoTempProgress);
            self.playerView.frame = _headPlayerView.bounds;
        }];
        
    }
}
//返回按钮代理方法
- (void)backToBeforeVC{
    
    if (!self.playerView.isRotate) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//在销毁控制器时一定要调用销毁方法 用来销毁监听
- (void)dealloc{
    
    [self.playerView deallocPlayer];
}



@end
