//
//  LMVideoPlayerView.h
//  Owhat_v4
//
//  Created by Leesim on 17/2/28.
//  Copyright © 2017年 Owhat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "XYVideoModel.h"

@class LMVideoPlayerView;

@protocol LMVideoPlayerViewDelegate <NSObject>
//全屏切换
- (void)fullScreenWithPlayerView:(LMVideoPlayerView *)videoPlayerView;
//返回
- (void)backToBeforeVC;

@end

@interface LMVideoPlayerView : UIView

//视频模型 包括视频的链接和标题
@property(nonatomic, strong) XYVideoModel *videoModel;

@property (assign, nonatomic) BOOL isRotate; //是否全屏

@property (nonatomic, weak) id<LMVideoPlayerViewDelegate>delegate;

//内存回收
- (void)deallocPlayer;

//判断是否播放 如果播放中  则暂停播放
- (void)playingOrNot;

//初始化
- (instancetype)initWithModel:(XYVideoModel*)model;

@end
