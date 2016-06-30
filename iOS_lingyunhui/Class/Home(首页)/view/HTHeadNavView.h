//
//  HTHeadNavView.h
//  head
//
//  Created by 刘琛 on 16/5/23.
//  Copyright © 2016年 cyjd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTHeadViewDelegate <NSObject>

@optional

/**
 *  中间3个按钮点击事件返回是几按的就是几
 *
 *  @param buttonType
 */
- (void)MidHeadButtonAction:(NSUInteger) buttonType;

/**
 *  按下搜索按钮
 */
- (void)searchButtonAction;

//显示二级菜单
- (void)showSecondMenu;


@end

@interface HTHeadNavView : UIView

@property (nonatomic, weak) id<HTHeadViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame AndFirstArray:(NSArray *) firstArray AndAddress: (NSString *) address;

- (void)upAndDownReduction;

- (void)resetLocation:(NSString *) address;

@end
