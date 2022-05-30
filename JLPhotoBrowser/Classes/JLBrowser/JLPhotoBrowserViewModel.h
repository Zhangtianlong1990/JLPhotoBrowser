//
//  JLPhotoBrowserViewModel.h
//  JLPhotoBrowser
//
//  Created by 张天龙 on 2022/5/29.
//  Copyright © 2022 BangGu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPhotoBrowserInputProtocol.h"
#import "JLPhotoBrowserOutputProtocol.h"

@interface JLPhotoBrowserViewModel : NSObject <JLPhotoBrowserInputProtocol>
- (instancetype)initWithOutputScreen:(id<JLPhotoBrowserOutputProtocol>)outputScreen;
@end

