//
//  LMVideoPlayerView.m
//  Owhat_v4
//
//  Created by Leesim on 17/2/28.
//  Copyright © 2017年 Owhat. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import <AVFoundation/AVAudioSession.h>
#import "LMVideoPlayerView.h"
#import "LZHProgressSlider.h"
#import "LZHButton.h"
#import "LRMacroDefinitionHeader.h"
#import "XYVideoModel.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "OWTaskTopAlphaImage.h"

#define videoTempProgress 16/25

typedef NS_ENUM(NSUInteger, Direction) {
    DirectionLeftOrRight,
    DirectionUpOrDown,
    DirectionNone
};

@interface LMVideoPlayerView()<IJKMediaUrlOpenDelegate,LZHButtonDelegate>

/* 视频播放器 */
@property(nonatomic, strong) id<IJKMediaPlayback>    player;
@property (nonatomic, strong)  OWTaskTopAlphaImage          *upPlayerView;
// 工具条
@property (strong, nonatomic) UIView          *toolView;
@property (strong, nonatomic) UIView          *navView;
@property (strong, nonatomic) UILabel         *videoTitle;
@property (strong, nonatomic) UIButton        *backBtn;
@property (strong, nonatomic) UIView          *sliderBackView;
@property (strong, nonatomic) LZHProgressSlider      *slider;

@property (nonatomic, strong) CADisplayLink            *link;
@property (nonatomic, assign) NSTimeInterval           lastTime;

//全屏按钮
@property (strong, nonatomic)  UIButton          *fullScreenBtn;

//添加手势的Button
@property (strong, nonatomic) LZHButton                *button;
//开始滑动的点
@property (assign, nonatomic) CGPoint                  startPoint;
//开始滑动时的亮度
@property (assign, nonatomic) CGFloat                  startVB;
//滑动方向
@property (assign, nonatomic) Direction                direction;
//滑动开始的播放进度
@property (assign, nonatomic) CGFloat                  startVideoRate;
//当期视频播放的进度
@property (assign, nonatomic) CGFloat                  currentRate;
//当前的播放时间
@property (strong, nonatomic)  UILabel           *currTimeLabel;
//总的播放时间
@property (strong, nonatomic) UILabel           *totalTimeLabel;
//全屏按钮
@property (strong, nonatomic) UIButton          *upFullScreenBtn;
//定时器
@property (nonatomic, retain) NSTimer                  *autoDismissTimer;

//toolbar上的开始暂停按钮
@property (strong, nonatomic) UIButton *startAndStopButton;

//首次开始的按钮
@property (nonatomic,strong) UIButton * firstPlayButton;

@end

@implementation LMVideoPlayerView{
    
    UISlider *systemSlider;
    UITapGestureRecognizer* singleTap;
}
#pragma mark - 初始化

- (instancetype)initWithModel:(XYVideoModel*)model
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width*videoTempProgress);
        
        //初始化播放控制器
        [self setupUpPlayerWith:model];
        //初始化UI
        [self setUIWithModel:model];
    }
    return self;
}


- (void)setUIWithModel:(XYVideoModel *)model{
    
    __weak __typeof(self) weakSelf = self;
    //背景view
    self.upPlayerView = [[OWTaskTopAlphaImage alloc]init];
    self.upPlayerView.contentMode =  UIViewContentModeScaleAspectFit;
    self.upPlayerView.userInteractionEnabled = YES;
    [self addSubview:self.upPlayerView];
    //顶部封面图
    self.upPlayerView.image = [UIImage imageNamed:model.coverimg];
    
    [self.upPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.mas_equalTo(0);
        
    }];
    
    
    //工具栏
    self.toolView = [[UIView alloc]init];
    self.toolView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.56];
    [self.upPlayerView addSubview:self.toolView];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(48);
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
    
    //标题
    self.videoTitle = [[UILabel alloc]init];
    self.videoTitle.font = [UIFont systemFontOfSize:14];
    self.videoTitle.textColor = [UIColor whiteColor];
    self.videoTitle.text = model.name;
    [self.navView addSubview:self.videoTitle];
    
    [self.videoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_offset(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(weakSelf.backBtn.mas_right).offset(16);
        make.right.mas_offset(-20);
        
    }];
    

    
    //添加自定义的Button到视频画面上 用于手势控制相关
    _button = [[LZHButton alloc]init];
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
    self.startAndStopButton.selected = YES;
    
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
    self.currTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.currTimeLabel.textColor = [UIColor whiteColor];
    [self.toolView addSubview:self.currTimeLabel];
    
    [self.currTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(weakSelf.startAndStopButton.mas_right).offset(5);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(41);
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
        make.width.mas_equalTo(41);
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
    self.slider = [[LZHProgressSlider alloc] initWithFrame:self.sliderBackView.bounds direction:AC_SliderDirectionHorizonal];
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
    

}
// 初始化视频
- (void)setupUpPlayerWith:(XYVideoModel*)model
{
    
    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:model.url withOptions:nil];
    [_player setShouldAutoplay:NO];
    UIView *playerView = [self.player view];
    playerView.frame = self.bounds;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:playerView];
    [self insertSubview:playerView atIndex:1];
    [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
    [self installMovieNotificationObservers];
    
    [_player prepareToPlay];
    
    
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(upadte)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.link.paused = YES;
}

- (BOOL)willOpenUrl:(IJKMediaUrlOpenData*) urlOpenData
{
    return YES;
}

#pragma mark - 播放暂停按钮事件

//首次进行播放按钮
-(void)firstPlayAction:(UIButton*)button{

    self.upPlayerView.image = nil;
    
    //底部工具栏隐藏关闭
    self.toolView.hidden = NO;
    //顶部导航隐藏关闭
    self.navView.hidden = NO;
    
    //执行开始
    [self playOrPause:self.startAndStopButton];
    
    //按钮移除
    [button removeFromSuperview];
    
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
//如果加载失败
- (void)reloadAction:(UIButton *)sender{
    
    //如果加载失败
    //如果按钮为播放状态
    if (self.startAndStopButton.selected == NO) {
        
        //如果结束时 状态为暂停 执行两次 再次播放
        [self playOrPause:self.startAndStopButton];
        [self playOrPause:self.startAndStopButton];
    }
    
}


- (void)backBtnClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(backToBeforeVC)]) {
        
        [self.delegate backToBeforeVC];
        
        if (self.isRotate) {
            
            [self fullScreenBtnCicked:self.fullScreenBtn];
        }
        
    }
    
}
//全屏
- (void)fullScreenBtnCicked:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(fullScreenWithPlayerView:)]) {
        
        self.isRotate = !self.isRotate;
        
        [self.delegate fullScreenWithPlayerView:self];
        
        [self.slider setNeedsDisplay];
        
        UIView *playerView = [self.player view];
        if (self.isRotate) {
            
            playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        }else{
            
            playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*videoTempProgress);
        }
        playerView.center = self.center;
        
    }
}
#pragma mark - 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
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
#pragma mark autoDismissBottomView
-(void)autoDismissBottomView:(NSTimer *)timer{
    
    if (![self.player isPlaying]) {//暂停状态
        
    }else{
        if (self.navView.alpha==1.0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.toolView.alpha = 0.0;
                self.navView.alpha = 0.0;
                //                self.playOrPauseBtn.alpha = 0.0;
                
            } completion:^(BOOL finish){
                
            }];
        }
    }
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
//处理滑块
- (void)progressValueChange:(LZHProgressSlider *)slider
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
//更新方法
- (void)upadte
{

    NSTimeInterval current = self.player.currentPlaybackTime;
    NSTimeInterval total = self.player.duration;
    //如果用户在手动滑动滑块，则不对滑块的进度进行设置重绘
    if (!self.slider.isSliding) {
        self.slider.sliderPercent = current/total;
    }
    if (current!=self.lastTime) {
  
        if (self.navView.alpha==1.0) {
         
        }else{
        
        }
        // 更新播放时间
        
        if (current<0) {
            
            current = 0;
        }
        
        if (current>total) {
            
            current = total;
        }
        
        self.currTimeLabel.text = [self stringWithTime:current];
        self.totalTimeLabel.text = [self stringWithTime:total];
        
    }else{

    }
    self.lastTime = current;
    //缓冲进度
    NSTimeInterval loadedTime = self.player.playableDuration;

    if (!self.slider.isSliding) {
        
        if (loadedTime/total>0.9) {
         
        self.slider.progressPercent = 1;
            
        }else{
        
        self.slider.progressPercent = loadedTime/total;
        
        }

    }
    //播放结束
    if ([self.currTimeLabel.text isEqualToString:self.totalTimeLabel.text] && ![self.totalTimeLabel.text isEqualToString:@"00:00:00"]) {
        
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

#pragma mark - 自定义Button的代理***********************************************************
#pragma mark - 开始触摸
/*************************************************************************/
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

//音量调节
- (void)volumeChanged:(NSNotification *)notification
{
    
    
    
}

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
//重写set方法
- (void)setVideoModel:(XYVideoModel *)videoModel{
    
    _videoModel = videoModel;
    
    [self changeCurrentplayerItemWithVideoModel];
}
//切换当前播放的内容
- (void)changeCurrentplayerItemWithVideoModel
{
    //移除当前player的监听
    [self.player shutdown];
    [self.player.view removeFromSuperview];
    [self removeMovieNotificationObservers];
    //关闭定时器
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    
    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.videoModel.url withOptions:nil];
    UIView *playerView = [self.player view];
    playerView.frame = self.bounds;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:playerView];
    //    [self insertSubview:playerView atIndex:1];
    [self insertSubview:playerView aboveSubview:self.navView];
    [_player setScalingMode:IJKMPMovieScalingModeAspectFit];
    [self installMovieNotificationObservers];
    
    if (![self.player isPlaying]) {
        [self.player prepareToPlay];
        
    }
    self.videoTitle.text = self.videoModel.name;
    //self.playOrPauseBtn.enabled = NO;
    //由暂停状态切换时候 开启定时器，将暂停按钮状态设置为播放状态
    self.link.paused = NO;
    self.startAndStopButton.selected = NO;
    self.slider.enabled = NO;
    
    
}
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
        self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
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
                
                //如果结束时 状态为暂停 执行两次 再次播放
                [self playOrPause:self.startAndStopButton];
                [self playOrPause:self.startAndStopButton];
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

#pragma mark Install Movie Notifications

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
#pragma mark - 内存回收
- (void)deallocPlayer
{
    [self.player shutdown];
    [self.link invalidate];
    // 关闭定时器
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    [self removeMovieNotificationObservers];
}
//判断是否正在播放 来决定是否暂停
- (void)playingOrNot{
    
    //如果为播放中 则进行暂停处理
    if ([(IJKFFMoviePlayerController*)self.player playbackState] == IJKMPMoviePlaybackStatePlaying) {
        
        [(IJKFFMoviePlayerController*)self.player pause];
        self.startAndStopButton.selected = !self.startAndStopButton.selected;
    }
    
}

@end

