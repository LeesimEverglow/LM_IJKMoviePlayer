//
//  LMIJKVideoPlayerVolumeBrightButton.h
//  LM_IJKMoivePlayer
//
//  Created by Leesim on 2018/6/1.
//  Copyright © 2018年 LiMing. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LMIJKVideoPlayerVolumeBrightButtonDelegate <NSObject>

/**
 * 开始触摸
 */
- (void)touchesBeganWithPoint:(CGPoint)point;

/**
 * 结束触摸
 */
- (void)touchesEndWithPoint:(CGPoint)point;

/**
 * 移动手指
 */
- (void)touchesMoveWithPoint:(CGPoint)point;

@end

@interface LMIJKVideoPlayerVolumeBrightButton : UIButton

/**
 * 传递点击事件的代理
 */
@property (weak, nonatomic) id <LMIJKVideoPlayerVolumeBrightButtonDelegate> touchDelegate;

@end
