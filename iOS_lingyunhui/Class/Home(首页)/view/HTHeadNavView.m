//
//  HTHeadNavView.m
//  head
//
//  Created by 刘琛 on 16/5/23.
//  Copyright © 2016年 cyjd. All rights reserved.
//
//72 28


#import "HTHeadNavView.h"

#define HTheadWidth [UIScreen mainScreen].bounds.size.width

#define HTheadHeight [UIScreen mainScreen].bounds.size.height

@interface HTHeadNavView()

@property (nonatomic, assign) CGFloat with;

@property (nonatomic, strong) UIView *redSlider;

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) UIButton *upAndDown;

@property (nonatomic, strong) UIButton *addressButton;

@property (nonatomic, assign) CGFloat addressWith;

@property (nonatomic, assign) CGFloat otherWith;

@end


@implementation HTHeadNavView

- (instancetype)initWithFrame:(CGRect)frame AndFirstArray:(NSArray *) firstArray AndAddress: (NSString *) address{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _addressWith = HTheadWidth * 60 / 320;
        
        _otherWith = HTheadWidth * 35 / 320;
        
        _addressButton = [[UIButton alloc] init];
        _addressButton.userInteractionEnabled = NO;
        [_addressButton setTitle:address forState:UIControlStateNormal];
        [_addressButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_addressButton setBackgroundImage:[UIImage imageNamed:@"xian1"] forState:UIControlStateNormal];
//        addressButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _addressButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:15];
        _addressButton.frame = CGRectMake(0, 0, _addressWith, 42);
        [self addSubview:_addressButton];
        [_addressButton.titleLabel sizeToFit];
        
        
        UIButton *searchButton = [[UIButton alloc] init];
        [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        searchButton.backgroundColor = [UIColor whiteColor];
        searchButton.frame = CGRectMake(HTheadWidth - _otherWith, 0, _otherWith, 42);
        searchButton.tag = 500;
        searchButton.adjustsImageWhenHighlighted = NO;
        [searchButton addTarget:self action:@selector(HTHeadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:searchButton];
        
        UIImageView *buttonBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xian2"]];
        buttonBgView.frame = CGRectMake(HTheadWidth - _otherWith - _otherWith, 0, _otherWith, 42);
        [self addSubview:buttonBgView];
        
        _upAndDown = [[UIButton alloc] init];
        [_upAndDown setImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
        _upAndDown.adjustsImageWhenHighlighted = NO;
        _upAndDown.backgroundColor = [UIColor clearColor];
//        [upAndDown setBackgroundImage:[UIImage imageNamed:@"xian2"] forState:UIControlStateNormal];
        _upAndDown.frame = CGRectMake(HTheadWidth - _otherWith - _otherWith, 0, _otherWith, 42);
        _upAndDown.tag = 1000;
        
        [_upAndDown addTarget:self action:@selector(HTHeadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_upAndDown];


        _with = (HTheadWidth - _otherWith - _otherWith - _addressWith) / 3 ;

        for (int i = 0; i < firstArray.count; i++) {
            UIButton *selectButton = [[UIButton alloc] init];
            if (i == 0) {
                self.selectedButton = selectButton;
                [selectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }else {
                [selectButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
            }
            selectButton.frame = CGRectMake(_addressWith + i * _with, 0, _with, 40);
            [selectButton setTitle:firstArray[i] forState:UIControlStateNormal];
            selectButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [selectButton addTarget:self action:@selector(HTHeadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.tag = i;
            [self addSubview:selectButton];
            
        }
        
        _redSlider = [[UIView alloc] initWithFrame:CGRectMake(_addressWith + _with * 0.25, 40, _with * 0.5, 2)];
        _redSlider.backgroundColor = [UIColor redColor];
        [self addSubview:_redSlider];
        
    }
    return  self;
}

#pragma 按钮点击事件

- (void)HTHeadButtonAction: (UIButton *) sender{
    if (sender.tag == 500) {
        if ([self.delegate respondsToSelector:@selector(searchButtonAction)]) {
            [self.delegate searchButtonAction];
        }
        
    }else if (sender.tag == 1000) {
        sender.tag = 2000;
        [UIView animateWithDuration:0.35 animations:^{
            sender.transform =  CGAffineTransformMakeRotation(M_PI);
        }];
        if ([self.delegate respondsToSelector:@selector(showSecondMenu)]) {
            [self.delegate showSecondMenu];
        }
        
    }else if (sender.tag == 2000) {
        sender.tag = 1000;
        
        [self upAndDownReduction];
        
    }else {
        
        
        [UIView animateWithDuration:0.35 animations:^{
            [self.selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _redSlider.frame = CGRectMake(sender.tag * _with + _addressWith + _with * 0.25, 40, _with * 0.5, 2);
            [sender setTitleColor:[UIColor redColor] forState: UIControlStateNormal];
            self.selectedButton = sender;
        }];
        
        if ([self.delegate respondsToSelector:@selector(MidHeadButtonAction:)]) {
            [self.delegate MidHeadButtonAction:sender.tag];
        }
    }
}

- (void)upAndDownReduction {
    [UIView animateWithDuration:0.35 animations:^{
        _upAndDown.transform =  CGAffineTransformIdentity;
    }];
}


- (void)resetLocation:(NSString *) address {
    [self.addressButton setTitle:address forState:UIControlStateNormal];
}




@end
