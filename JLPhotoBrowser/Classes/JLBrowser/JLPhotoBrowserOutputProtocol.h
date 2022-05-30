//
//  JLPhotoBrowserOutputProtocol.h
//  JLPhotoBrowser
//
//  Created by 张天龙 on 2022/5/29.
//  Copyright © 2022 BangGu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPhoto.h"
#import "UIImageView+WebCache.h"

@protocol JLPhotoBrowserOutputProtocol <NSObject>

- (void)setProgressViewVisibilityWithPhoto:(JLPhoto *)aPhoto visibility:(BOOL)visibility;
- (void)setupProgress:(CGFloat)progress photo:(JLPhoto *)aPhoto;
- (void)callbackImage:(UIImage *)image cacheType:(SDImageCacheType)cacheType aPhoto:(JLPhoto *)aPhoto;
- (void)enlargeSmallScrollView:(UITapGestureRecognizer *)aTap;
- (void)shrinkSmallScrollViewAndDismiss:(UITapGestureRecognizer *)aTap;
- (void)dismissBrowser:(UITapGestureRecognizer *)aTap;
@end

