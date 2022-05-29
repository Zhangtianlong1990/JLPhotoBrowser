//
//  JLPhoto.m
//  JLPhotoBrowser
//
//  Created by liao on 15/12/24.
//  Copyright © 2015年 BangGu. All rights reserved.
//

#import "JLPhoto.h"

@implementation JLPhoto

- (instancetype)initWithSourceImageView:(UIImageView *)sourceImageView bigImgUrl:(NSString *)bigImgUrl{
    self = [super init];
    if (self) {
        self.sourceImageView = sourceImageView;
        self.bigImgUrl = bigImgUrl;
        //不裁剪的话，缩放的时候会看到两边多余的部分
        self.clipsToBounds = YES;
        self.userInteractionEnabled  = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

@end
