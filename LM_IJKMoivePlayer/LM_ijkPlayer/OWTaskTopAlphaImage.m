//
//  OWTaskTopAlphaImage.m
//  Owhat_v4
//
//  Created by Leesim on 16/12/19.
//  Copyright © 2016年 Owhat. All rights reserved.
//

#import "OWTaskTopAlphaImage.h"

#import "Masonry.h"

@interface OWTaskTopAlphaImage ()

//灰色蒙板的view
@property (nonatomic,strong) UIView * grayView;

@end

@implementation OWTaskTopAlphaImage

-(UIView *)grayView{

    if (!_grayView) {
        
        _grayView = [[UIView alloc]init];
        
        _grayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.08];
        
        [self addSubview:_grayView];
        
    }
    return _grayView;
}


- (instancetype)init
{
    self = [super init];
    if (self) {

        [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.bottom.left.right.mas_equalTo(0);

        }];
    
    }
    return self;
}



@end
