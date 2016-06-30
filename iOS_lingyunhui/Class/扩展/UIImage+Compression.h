//
//  UIImage+Compression.h
//  iOS_FanmoreIndiana
//
//  Created by 刘琛 on 16/4/6.
//  Copyright © 2016年 刘琛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compression)

//压缩图片质量
+(UIImage *)reduceImage:(UIImage *)image percent:(float)percent;
//压缩图片尺寸
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;


@end
