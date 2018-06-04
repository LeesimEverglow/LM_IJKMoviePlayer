//
//  LMIJKVideoPlayerView.m
//  Owhat_v4
//
//  Created by Leesim on 2018/5/11.
//  Copyright © 2018年 Owhat. All rights reserved.
//

#import "LMIJKVideoPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "LMIJKVideoPlayerProgressSlider.h"
#import "LMIJKVideoPlayerVolumeBrightButton.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "LRMacroDefinitionHeader.h"
#import "Masonry.h"

typedef NS_ENUM(NSUInteger, Direction) {
    DirectionLeftOrRight,
    DirectionUpOrDown,
    DirectionNone
};
@interface LMIJKVideoPlayerView ()<IJKMediaUrlOpenDelegate,LMIJKVideoPlayerVolumeBrightButtonDelegate>
{
    //系统音量的滑动控制 用来调节音量
    UISlider *systemSlider;
    //点击手势
    UITapGestureRecognizer* singleTap;
}

/* 视频播放器 */
@property(nonatomic, strong) id<IJKMediaPlayback>player;

// 工具条
@property (nonatomic,strong) UIView * toolView;
@property (nonatomic,strong) UIView * navView;
@property (nonatomic,strong) UIButton * backBtn;
@property (nonatomic,strong) UIView * sliderBackView;
@property (nonatomic,strong) LMIJKVideoPlayerProgressSlider * slider;
@property (nonatomic,strong) CADisplayLink * link;
@property (nonatomic,assign) NSTimeInterval lastTime;
//全屏按钮
@property (strong, nonatomic)  UIButton * fullScreenBtn;
//添加手势的Button
@property (strong, nonatomic) LMIJKVideoPlayerVolumeBrightButton * button;
//开始滑动的点
@property (assign, nonatomic) CGPoint startPoint;
//开始滑动时的亮度
@property (assign, nonatomic) CGFloat startVB;
//滑动方向
@property (assign, nonatomic) Direction direction;
//滑动开始的播放进度
@property (assign, nonatomic) CGFloat startVideoRate;
//当期视频播放的进度
@property (assign, nonatomic) CGFloat currentRate;
//当前的播放时间
@property (strong, nonatomic)  UILabel * currTimeLabel;
//总的播放时间
@property (strong, nonatomic) UILabel * totalTimeLabel;
//定时器
@property (nonatomic, retain) NSTimer * autoDismissTimer;
//toolbar上的开始暂停按钮
@property (strong, nonatomic) UIButton * startAndStopButton;
//首次开始的按钮
@property (nonatomic,strong) UIButton * firstPlayButton;
//是否全屏
@property (assign, nonatomic) BOOL isRotate;
//封面图
@property (nonatomic,strong) UIImage * coverImage;
//推出前的父视图
@property (nonatomic,weak) UIView * movieViewParentView;
//推出前的frame
@property (nonatomic,assign) CGRect movieViewFrame;

@end;

@implementation LMIJKVideoPlayerView



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareUI];
    }
    return self;
}


- (void)prepareUI{
    
    __weak __typeof(self) weakSelf = self;
    //背景view
    self.upPlayerView = [[UIImageView alloc]init];
    self.upPlayerView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.upPlayerView];
    self.upPlayerView.userInteractionEnabled = YES;
    self.upPlayerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.upPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    //工具栏
    self.toolView = [[UIView alloc]init];
    self.toolView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.56];
    [self.upPlayerView addSubview:self.toolView];
    
    CGFloat toolHeight = iPhoneX ? (TabBarHeight):(48);
    
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(toolHeight);
    }];
    
    //导航栏
    self.navView = [[UIView alloc]init];
    self.navView.backgroundColor = LRRGBAColor(0, 0, 0, 0.56);
    //先隐藏
    self.navView.hidden = YES;
    [self.upPlayerView addSubview:self.navView];
    
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.top.mas_offset(0);
        make.height.mas_equalTo(48);
    }];
    
    //返回按钮
    self.backBtn = [[UIButton alloc]init];
    [self.navView addSubview:self.backBtn];
    [self.backBtn setImage:[UIImage imageNamed:@"nav_btn_back_white"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(0);
        make.top.mas_offset(0);
        make.height.width.mas_equalTo(48);
    }];
    
    
    //添加自定义的Button到视频画面上 用于手势控制相关
    _button = [[LMIJKVideoPlayerVolumeBrightButton alloc]init];
    _button.touchDelegate = self;
    [self addSubview:_button];
    [_button mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.toolView.mas_top);
    }];
    
    
    //播放按钮 初始化界面 将中心的播放按钮隐藏
    self.firstPlayButton = [[UIButton alloc]init];
    [self.firstPlayButton setImage:[UIImage imageNamed:@"icon_video_play"] forState:UIControlStateNormal];
    [self addSubview:self.firstPlayButton];
    [self.firstPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(60);
        make.center.equalTo(weakSelf);
        
    }];
    [self.firstPlayButton addTarget:self action:@selector(firstPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //播放按钮
    self.startAndStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toolView addSubview:self.startAndStopButton];
    [self.startAndStopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.mas_equalTo(0);
        make.height.width.mas_equalTo(48);
        
    }];
    
    self.startAndStopButton.showsTouchWhenHighlighted = YES;
    [self.startAndStopButton setImage:[UIImage imageNamed:@"icon_video_pause_big"] forState:UIControlStateNormal];
    [self.startAndStopButton setImage:[UIImage imageNamed:@"icon_video_play_big"] forState:UIControlStateSelected];
    [self.startAndStopButton addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    
    //全屏按钮
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toolView addSubview:self.fullScreenBtn];
    
    //全屏的事件
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnCicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.width.mas_equalTo(48);
        
    }];
    
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"icon_video_enlarge"] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"icon_video_zoom_small"] forState:UIControlStateSelected];
    
    
    //当前进度时间
    self.currTimeLabel = [[UILabel alloc]init];
    self.currTimeLabel.font = [UIFont systemFontOfSize:9];
    self.currTimeLabel.text = @"00:00:00";
    self.currTimeLabel.textAlignment = NSTextAlignmentRight;
    self.currTimeLabel.textColor = [UIColor whiteColor];
    [self.toolView addSubview:self.currTimeLabel];
    
    [self.currTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.startAndStopButton.mas_right).offset(5);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(43);
    }];
    
    //全部时间
    self.totalTimeLabel = [[UILabel alloc]init];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:9];
    self.totalTimeLabel.text = @"--:--:--";
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.toolView addSubview:self.totalTimeLabel];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.fullScreenBtn.mas_left).offset(-5);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(43);
    }];
    

    //滑块的背景
    self.sliderBackView = [[UIView alloc]init];
    [self.toolView addSubview:self.sliderBackView];
    [self.sliderBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.currTimeLabel.mas_right).offset(5);
        make.right.mas_equalTo(weakSelf.totalTimeLabel.mas_left).offset(-5);
        make.top.bottom.mas_equalTo(0);
    }];
    
    
    //滑块显示进度和缓冲
    self.slider = [[LMIJKVideoPlayerProgressSlider alloc] initWithFrame:self.sliderBackView.bounds direction:AC_SliderDirectionHorizonal];
    [self.sliderBackView addSubview:self.slider];
    self.slider.enabled = NO;
    [self.slider addTarget:self action:@selector(progressValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sliderBackView);
    }];
    
    //系统的音量
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    [self addSubview:volumeView];
    //转移到屏幕视线外的地方显示
    volumeView.frame = CGRectMake(-1000,-1000, 100, 100);
    [volumeView sizeToFit];
    
    systemSlider = [[UISlider alloc]init];
    systemSlider.backgroundColor = [UIColor clearColor];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            systemSlider = (UISlider *)view;
        }
    }
    systemSlider.hidden = YES;
    systemSlider.autoresizesSubviews = NO;
    systemSlider.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:systemSlider];
    
    // 单击的 Recognizer
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1; // 单击
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    //默认首次进入页面 隐藏
    self.toolView.hidden = YES;
    self.startAndStopButton.selected = YES;
}


-(void)setVideoUrl:(NSString *)videoUrl{
    _videoUrl = videoUrl;
    //旋转方向
    NSInteger rotationNumber = [self degressFromVideoFileWithURL:[NSURL URLWithString:videoUrl]];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault]; //使用默认配置
    [options setPlayerOptionIntValue:1 forKey:@"auto_convert"];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoUrl] withOptions:options];
    //默认为自动播放 该属性使得视频不进行自动播放
    //如果需要自动播放 则需要去除该shushing
    [self.player setShouldAutoplay:NO];
    UIView *playerView = [self.player view];
    if (rotationNumber == 90) {
        playerView.frame = CGRectMake(playerView.frame.origin.x,playerView.frame.origin.y, self.bounds.size.height, self.bounds.size.width);
        playerView.transform = CGAffineTransformMakeRotation(M_PI_2);
        playerView.frame = CGRectMake(0,0, playerView.frame.size.width, playerView.frame.size.height);
    }else{
        playerView.frame = self.bounds;
    }
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:playerView];
    [self sendSubviewToBack:playerView];
    [self.player setScalingMode:IJKMPMovieScalingModeAspectFit];
    [self installMovieNotificationObservers];
    [self.player prepareToPlay];
    
}


//音量调节
- (void)volumeChanged:(NSNotification *)notification
{

}
//即将打开url链接
-(void)willOpenUrl:(IJKMediaUrlOpenData*)urlOpenData
{
    
}

//首次进行播放按钮
-(void)firstPlayAction:(UIButton*)button{
    //正式进入播放状态
    [self beginPlayMediaWithButton:button];
}

//正式开始播放视频
- (void)beginPlayMediaWithButton:(UIButton *)button{
    //开始播放
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(upadte)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.link.paused = YES;
    //执行开始
    [self playOrPause:self.startAndStopButton];
    self.firstPlayButton.hidden = YES;
    //隐藏视频播放的第一帧
    self.upPlayerView.image = nil;
    //隐藏颜色
    self.upPlayerView.backgroundColor = [UIColor clearColor];
}
// 暂停按钮的监听
- (void)playOrPause:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == NO) {
        [self.player play];
        self.link.paused = NO;

    }else{
        [self.player pause];
        self.link.paused = YES;

    }
}
//全屏之后触发的方法
- (void)backBtnClicked:(id)sender {
    if (self.isRotate) {
        [self fullScreenBtnCicked:self.fullScreenBtn];
    }
}
//点击全屏按钮触发的方法
- (void)fullScreenBtnCicked:(UIButton *)sender {
    
        sender.selected = !sender.selected;
        self.isRotate = !self.isRotate;
        [self.slider setNeedsDisplay];

        if (self.isRotate) {
            self.navView.hidden = NO;
            [self.toolView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(48);
            }];
            //即将进入全屏幕之前 记录当前视图的父视图和记录进入之前的frame
            self.movieViewParentView = self.superview;
            self.movieViewFrame = self.frame;
            //记录之后将视频控件 加入进入到当前window界面上
            CGRect rectInWindow = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
            [self removeFromSuperview];
            self.frame = rectInWindow;
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            
            [UIView animateWithDuration:0.5 animations:^{
                //同时改变视频播放界面的transform
                self.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.bounds = CGRectMake(0, 0, CGRectGetHeight(self.superview.bounds), CGRectGetWidth(self.superview.bounds));
                self.center = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
                self.upPlayerView.frame = self.bounds;
            } completion:^(BOOL finished) {
                
            }];
            
        }else{
            self.navView.hidden = YES;
            CGFloat toolHeight = iPhoneX ? (TabBarHeight):(48);
            [self.toolView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(toolHeight);
            }];
            self.button.userInteractionEnabled = YES;
            CGRect frame = [self.movieViewParentView convertRect:self.movieViewFrame toView:[UIApplication sharedApplication].keyWindow];
            [UIView animateWithDuration:0.5 animations:^{
                self.transform = CGAffineTransformIdentity;
                self.frame = frame;
                self.upPlayerView.frame = self.bounds;
            } completion:^(BOOL finished) {
                /*
                 * movieView回到小屏位置
                 */
                [self removeFromSuperview];
                self.frame = self.movieViewFrame;
                [self.movieViewParentView addSubview:self];
    
            }];
        }
}
#pragma mark - 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.toolView.alpha == 0.0) {
            self.toolView.alpha = 1.0;
            self.navView.alpha = 1.0;
        }else{
            self.toolView.alpha = 0.0;
            self.navView.alpha = 0.0;
        }
    } completion:^(BOOL finish){
        
    }];
}
#pragma mark 自动消失监听计时器
-(void)autoDismissBottomView:(NSTimer *)timer{
    if (![self.player isPlaying]) {//暂停状态
    }else{
        if (self.navView.alpha==1.0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.toolView.alpha = 0.0;
                self.navView.alpha = 0.0;
            } completion:^(BOOL finish){

            }];
        }
    }
}
//处理滑块
- (void)progressValueChange:(LMIJKVideoPlayerProgressSlider *)slider
{
    NSTimeInterval duration = self.slider.sliderPercent* self.player.duration;
    //设置正在播放时间
    self.currTimeLabel.text = [self stringWithTime:duration];
    // 设置当前播放时间
    self.player.currentPlaybackTime = duration;
    //如果不在播放中 则开始播放
    if (![self.player isPlaying]) {
        self.startAndStopButton.selected = NO;
        [self.player play];
        self.link.paused = NO;
    }
}
//播放视频的过程中 不断调用监控状态的方法
- (void)upadte
{
    //保证播放状态图片为空
    self.toolView.hidden = NO;
    NSTimeInterval current = self.player.currentPlaybackTime;
    NSTimeInterval total = self.player.duration;
    //如果用户在手动滑动滑块，则不对滑块的进度进行设置重绘
    if (!self.slider.isSliding) {
        CGFloat playendpercent = 0;
        //IJKPlayer 对currentPlaybackTime duration 两个属性的获取并不准确
        //所以经常会出现当前播放时间快到结尾的时候不能跟总时间对应上的情况
        if (total>10&&total<15) {
            playendpercent = 0.95;
        }else if (total>5&&total<10){
            playendpercent = 0.91;
        }else if (total>0&&total<5){
            playendpercent = 0.86;
        }else if(total>15){
            playendpercent = 0.99;
        }
        //如果正在播放才去改变当前播放时间 防止播放时间突然变动
        if (current/total>playendpercent) {
            self.slider.sliderPercent = 1.0;
        }else{
            self.slider.sliderPercent = current/total;
        }
    }
    if (current!=self.lastTime) {
        // 更新播放时间
        if (current<0) {
            current = 0;
        }
        if (current>total) {
            current = total;
        }
        //如果正在播放才去改变当前播放时间 防止播放时间突然变动
        self.currTimeLabel.text = [self stringWithTime:current];
        self.totalTimeLabel.text = [self stringWithTime:total];
        
    }
    self.lastTime = current;
    //缓冲进度
    NSTimeInterval loadedTime = self.player.playableDuration;
    if (!self.slider.isSliding) {
        if (loadedTime/total>0.8) {
            self.slider.progressPercent = 1;
        }else{
            self.slider.progressPercent = loadedTime/total;
        }
    }
    if (current >= total && ![self.totalTimeLabel.text isEqualToString:@"00:00:00"] && total != 0) {
    
        //播放结束 重置状态
        self.slider.sliderPercent = 0;
        self.lastTime = 0;
        self.startAndStopButton.selected = !self.startAndStopButton.selected;
        self.link.paused = YES;
        self.currTimeLabel.text = [self stringWithTime:0];
        self.player.currentPlaybackTime = 0;
        [self.player pause];
        [UIView animateWithDuration:0.5 animations:^{
            self.toolView.alpha = 1.0;
            self.navView.alpha = 1.0;
        } completion:^(BOOL finish){
        }];
    }
}

#pragma mark - 开始触摸 自定义Button的代理
- (void)touchesBeganWithPoint:(CGPoint)point {
    //记录首次触摸坐标
    self.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    if (self.startPoint.x <= self.button.frame.size.width / 2.0) {
        //亮度
        self.startVB = [UIScreen mainScreen].brightness;
    } else {
        //音/量
        self.startVB = systemSlider.value;
    }
    //方向置为无
    self.direction = DirectionNone;
    //记录当前视频播放的进度
    NSTimeInterval current = self.player.currentPlaybackTime;
    NSTimeInterval total = self.player.duration;
    self.startVideoRate = current/total;
    
}
#pragma mark - 结束触摸
- (void)touchesEndWithPoint:(CGPoint)point {
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    if ((panPoint.x >= -5 && panPoint.x <= 5) && (panPoint.y >= -5 && panPoint.y <= 5)) {
        [self handleSingleTap:singleTap];
        return;
    }
    if (self.direction == DirectionLeftOrRight) {
        if (self.player.isPreparedToPlay) {
            NSTimeInterval duration = self.currentRate* self.player.duration;
            // 设置当前播放时间
            self.player.currentPlaybackTime = duration;
            [self.player play];
        }
    }
    else if (self.direction == DirectionUpOrDown){
    }
}

#pragma mark - 拖动
- (void)touchesMoveWithPoint:(CGPoint)point {
    //得出手指在Button上移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    //分析出用户滑动的方向
    if (self.direction == DirectionNone) {
        if (panPoint.x >= 30 || panPoint.x <= -30) {
            //进度
            self.direction = DirectionLeftOrRight;
        } else if (panPoint.y >= 30 || panPoint.y <= -30) {
            //音量和亮度
            self.direction = DirectionUpOrDown;
        }
    }
    if (self.direction == DirectionNone) {
        return;
    } else if (self.direction == DirectionUpOrDown) {
        //音量和亮度
        if (self.startPoint.x <= self.button.frame.size.width / 2.0) {
            //调节亮度
            if (panPoint.y < 0) {
                //增加亮度
                [[UIScreen mainScreen] setBrightness:self.startVB + (-panPoint.y / 30.0 / 10)];
            } else {
                //减少亮度
                [[UIScreen mainScreen] setBrightness:self.startVB - (panPoint.y / 30.0 / 10)];
            }
            
        } else {
            //音量
            if (panPoint.y < 0) {
                //增大音量
                [systemSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
                if (self.startVB + (-panPoint.y / 30 / 10) - systemSlider.value >= 0.1) {
                    [systemSlider setValue:0.1 animated:NO];
                    [systemSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
                }
                
            } else {
                //减少音量
                [systemSlider setValue:self.startVB - (panPoint.y / 30.0 / 10) animated:YES];
            }
        }
    } else if (self.direction == DirectionLeftOrRight ) {
        //进度
        CGFloat rate = self.startVideoRate + (panPoint.x / 30.0 / 20.0);
        if (rate > 1) {
            rate = 1;
        } else if (rate < 0) {
            rate = 0;
        }
        self.currentRate = rate;
        self.slider.sliderPercent = self.currentRate;
    }
}

#pragma mark 注册视频监听
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            //播放结束后 重置状态
            self.slider.sliderPercent = 0;
            self.lastTime = 0;
            self.startAndStopButton.selected = !self.startAndStopButton.selected;
            self.link.paused = YES;
            self.currTimeLabel.text = [self stringWithTime:0];
            self.player.currentPlaybackTime = 0;
            [self.player pause];
            self.firstPlayButton.hidden = NO;
            self.toolView.hidden = YES;
            
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:{
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            self.link.paused = YES;
            break;
        }
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    self.slider.enabled = YES;
    
    self.link.paused = NO;
    //5s dismiss bottomView
    if (self.autoDismissTimer==nil) {
        self.autoDismissTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    }
}
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            
            //如果按钮为播放状态
            if (self.startAndStopButton.selected == NO) {
            }
            
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    // add event handler, for this example, it is `volumeChange:` method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}
//获取url视频的播放方向
- (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url
{
    NSUInteger degress = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    
    return degress;
}

//时间显示转换
- (NSString *)stringWithTime:(NSTimeInterval)time
{
    NSInteger h = time / 3600;
    NSInteger m = ((int)time%3600)/60;
    NSInteger s = (NSInteger)time % 60;
    
    NSString *stringtime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", h, m, (long)s];
    
    return stringtime;
}

//根据视频的url获取视频的第一帧图片
//比较消时，注意放入异步线程处理
- (UIImage*)getVideoPreViewImageWithUrl:(NSString *)videoPath
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:videoPath] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return img;
}

//销毁播放器的步骤
- (void)deallocPlayer
{
    [self.player shutdown];
    [self.link invalidate];
    // 关闭定时器
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    [self removeMovieNotificationObservers];
}
//暂停播放
- (void)pausePlayer{
    if ([self.player isPlaying]) {
        self.startAndStopButton.selected = YES;
        self.firstPlayButton.hidden = NO;
        [self.player pause];
        self.link.paused = YES;
    }
}
//开始播放
-(void)playPlayer{
    if (![self.player isPlaying]) {
        [self playOrPause:self.startAndStopButton];
        self.startAndStopButton.selected = NO;
    }
}

@end
