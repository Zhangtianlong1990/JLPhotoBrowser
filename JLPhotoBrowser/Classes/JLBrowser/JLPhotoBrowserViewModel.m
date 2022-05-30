//
//  JLPhotoBrowserViewModel.m
//  JLPhotoBrowser
//
//  Created by 张天龙 on 2022/5/29.
//  Copyright © 2022 BangGu. All rights reserved.
//

#import "JLPhotoBrowserViewModel.h"
#import "UIImageView+WebCache.h"
#import "JLPhotoBrowserOutputProtocol.h"

@interface JLPhotoBrowserViewModel()
@property (nonatomic,weak) id<JLPhotoBrowserOutputProtocol> outputScreen;
@end

@implementation JLPhotoBrowserViewModel

- (instancetype)initWithOutputScreen:(id<JLPhotoBrowserOutputProtocol>)outputScreen
{
    self = [super init];
    if (self) {
        self.outputScreen = outputScreen;
    }
    return self;
}

- (void)queryDiskCacheWithPhoto:(JLPhoto *)aPhoto{
    //检查图片是否已经缓存过
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:aPhoto.bigImgUrl done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image==nil) {//没有缓存过就显示loading
            [self.outputScreen setProgressViewVisibilityWithPhoto:aPhoto visibility:false];
        }
    }];
}
- (void)setImageWithPhoto:(JLPhoto *)aPhoto{
    [aPhoto sd_setImageWithURL:[NSURL URLWithString:aPhoto.bigImgUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //设置进度条
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.outputScreen setupProgress:(CGFloat)receivedSize/(CGFloat)expectedSize photo:aPhoto];
        });
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [self.outputScreen callbackImage:image cacheType:cacheType aPhoto:aPhoto];
        
    }];
}
- (void)didDoubleClickPhoto:(UITapGestureRecognizer *)aTap{
    [self.outputScreen enlargeSmallScrollView:aTap];
}
- (void)didSimgleClickPhoto:(UITapGestureRecognizer *)aTap{
    [self.outputScreen shrinkSmallScrollViewAndDismiss:aTap];
}
- (void)didClickProgressView:(UITapGestureRecognizer *)aTap{
    [self.outputScreen dismissBrowser:aTap];
}

@end
