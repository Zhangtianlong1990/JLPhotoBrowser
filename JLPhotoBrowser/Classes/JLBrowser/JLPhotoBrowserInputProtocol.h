//
//  JLPhotoBrowserInputProtocol.h
//  JLPhotoBrowser
//
//  Created by 张天龙 on 2022/5/29.
//  Copyright © 2022 BangGu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPhoto.h"

@protocol JLPhotoBrowserInputProtocol <NSObject>
- (void)queryDiskCacheWithPhoto:(JLPhoto *)aPhoto;
- (void)setImageWithPhoto:(JLPhoto *)aPhoto;
- (void)didDoubleClickPhoto:(UITapGestureRecognizer *)aTap;
- (void)didSimgleClickPhoto:(UITapGestureRecognizer *)aTap;
- (void)didClickProgressView:(UITapGestureRecognizer *)aTap;
@end


