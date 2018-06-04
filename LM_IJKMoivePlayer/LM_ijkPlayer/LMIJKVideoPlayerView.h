//
//  LMIJKVideoPlayerView.h
//  Owhat_v4
//
//  Created by Leesim on 2018/5/11.
//  Copyright © 2018年 Owhat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMIJKVideoPlayerView : UIView

@property (nonatomic, strong)  UIImageView * upPlayerView;
/**
 视频播放的地址
 1.支持录播视频流
 2.支持直播hls rtmp 直播流
 */
@property (nonatomic,copy) NSString * videoUrl;

/**
 视频播放控件销毁的时候 需要进行移除的方法
 */
- (void)deallocPlayer;

@end
