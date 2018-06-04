//
//  LMIJKVideoPlayerProgressSlider.h
//  LM_IJKMoivePlayer
//
//  Created by Leesim on 2018/6/1.
//  Copyright © 2018年 LiMing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LMIJKVideoPlayerProgressSliderDirection){
    AC_SliderDirectionHorizonal  =   0,
    AC_SliderDirectionVertical   =   1
};


@interface LMIJKVideoPlayerProgressSlider : UIControl


@property (nonatomic, assign) CGFloat minValue;//最小值
@property (nonatomic, assign) CGFloat maxValue;//最大值
@property (nonatomic, assign) CGFloat value;//滑动值
@property (nonatomic, assign) CGFloat sliderPercent;//滑动百分比
@property (nonatomic, assign) CGFloat progressPercent;//缓冲的百分比
@property (nonatomic, assign) BOOL isHiddenThumbImage; //是否隐藏外层圆圈

@property (nonatomic, assign) BOOL isSliding;//是否正在滑动  如果在滑动的是偶外面监听的回调不应该设置sliderPercent progressPercent 避免绘制混乱

@property (nonatomic, assign) LMIJKVideoPlayerProgressSliderDirection direction;//方向

- (id)initWithFrame:(CGRect)frame direction:(LMIJKVideoPlayerProgressSliderDirection)direction;

@end
