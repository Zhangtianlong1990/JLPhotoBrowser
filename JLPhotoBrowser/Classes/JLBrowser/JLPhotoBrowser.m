//
//  JLScrollView.m
//  JLPhotoBrowser
//
//  Created by liao on 15/12/24.
//  Copyright © 2015年 BangGu. All rights reserved.
//

//屏幕宽
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define JLKeyWindow [UIApplication sharedApplication].keyWindow

#define bigScrollVIewTag 101

#import "JLPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "JLPieProgressView.h"
#import "JLPhotoBrowserOutputProtocol.h"
#import "JLPhotoBrowserViewModel.h"

@interface JLPhotoBrowser()<UIScrollViewDelegate,JLPhotoBrowserOutputProtocol>
/**
 *  底层滑动的scrollview
 */
@property (nonatomic,weak) UIScrollView *bigScrollView;
/**
 *  黑色背景view
 */
@property (nonatomic,weak) UIView *blackView;
/**
 *  原始frame数组
 */
@property (nonatomic,strong) NSMutableArray *sourceImageRects;
@property (nonatomic,strong) NSMutableArray<JLPieProgressView *> *progressViews;
@property (nonatomic,strong) JLPhotoBrowserViewModel *viewModel;
@end

@implementation JLPhotoBrowser

-(NSMutableArray *)sourceImageRects{
    if (_sourceImageRects==nil) {
        _sourceImageRects = [NSMutableArray array];
    }
    return _sourceImageRects;
}

- (NSMutableArray *)progressViews{
    if (_progressViews == nil) {
        _progressViews = [NSMutableArray array];
    }
    return _progressViews;
}

+ (instancetype)photoBrowserWithPhotos:(NSArray<JLPhoto *> *)photos currentIndex:(int)currentIndex{
    return [[self alloc] initWithPhotos:photos currentIndex:currentIndex];
}

- (instancetype)initWithPhotos:(NSArray<JLPhoto *> *)photos currentIndex:(int)currentIndex{
    self = [super init];
    if (self) {
        
        self.photos = photos;
        self.currentIndex = currentIndex;
        [self initWithViewModel];
        [self convertImageRects];
        [self setupViews];
        
    }
    return self;
}

- (void)initWithViewModel{
    self.viewModel = [[JLPhotoBrowserViewModel alloc] initWithOutputScreen:self];
}

-(void)show{
    
    if (self.photos == nil || self.photos.count == 0 || self.currentIndex < 0) {
        NSLog(@"photos 或者 currentIndex 数据错误");
        return;
    }
    
    //1.添加photoBrowser
    [JLKeyWindow addSubview:self];
    
    //4.创建子视图
    [self setupSmallScrollViews];
    
}

#pragma mark 创建子视图

-(void)setupSmallScrollViews{
    
    for (int i=0; i<self.photos.count; i++) {
        
        UIScrollView *smallScrollView = [self setupSmallScrollView:i];
        JLPhoto *photo = [self addTapWithTag:i];
        [smallScrollView addSubview:photo];
        
        JLPieProgressView *progressView = [self creatProgressWithTag:i];
        [smallScrollView addSubview:progressView];
        [self.progressViews addObject:progressView];
        
        //检查图片是否已经缓存过
        [self.viewModel queryDiskCacheWithPhoto:photo];
        [self.viewModel setImageWithPhoto:photo];
        
    }
    
    
}

- (void)setupPhotoFrame:(JLPhoto *)photo{
    
    UIScrollView *smallScrollView = (UIScrollView *)photo.superview;
    
    self.blackView.alpha = 1.0;
    
    CGFloat ratio = (double)photo.image.size.height/(double)photo.image.size.width;
    
    CGFloat bigW = ScreenWidth;
    CGFloat bigH = ScreenWidth*ratio;
    
    if (bigH<ScreenHeight) {
        photo.bounds = CGRectMake(0, 0, bigW, bigH);
        photo.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    }else{//设置长图的frame
        photo.frame = CGRectMake(0, 0, bigW, bigH);
        smallScrollView.contentSize = CGSizeMake(ScreenWidth, bigH);
    }
    
}

- (UIScrollView *)setupSmallScrollView:(int)tag{
    
    UIScrollView *smallScrollView = [[UIScrollView alloc] init];
    smallScrollView.backgroundColor = [UIColor clearColor];
    smallScrollView.tag = tag;
    smallScrollView.frame = CGRectMake(ScreenWidth*tag, 0, ScreenWidth, ScreenHeight);
    smallScrollView.delegate = self;
    smallScrollView.maximumZoomScale=3.0;
    smallScrollView.minimumZoomScale=1;
    [self.bigScrollView addSubview:smallScrollView];
    
    return smallScrollView;
    
}

- (JLPhoto *)addTapWithTag:(int)tag{
    
    JLPhoto *photo = self.photos[tag];
    photo.index = tag;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [photo addGestureRecognizer:doubleTap];
    [photo addGestureRecognizer:singleTap];
    
    //zonmTap失败了再执行photoTap，否则zonmTap永远不会被执行
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    return photo;
    
}

- (JLPieProgressView *)creatProgressWithTag:(int)tag{
    
    JLPieProgressView *progressView = [[JLPieProgressView alloc] init];
    progressView.tag = tag;
    progressView.frame = CGRectMake(0,0 , 80, 80);
    progressView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    progressView.hidden = YES;
    UITapGestureRecognizer *progressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressTap:)];
    [progressView addGestureRecognizer:progressTap];
    return progressView;
    
}

#pragma mark - Action

-(void)doubleTap:(UITapGestureRecognizer *)doubleTap{
    [self.viewModel didDoubleClickPhoto:doubleTap];
}

-(void)singleTap:(UITapGestureRecognizer *)singleTap{
    [self.viewModel didSimgleClickPhoto:singleTap];
}

-(void)progressTap:(UITapGestureRecognizer *)tap{
    [self.viewModel didClickProgressView:tap];
}

#pragma mark UIScrollViewDelegate

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.tag==bigScrollVIewTag) return nil;
    
    JLPhoto *photo = self.photos[scrollView.tag];
    return photo;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if (scrollView.tag==bigScrollVIewTag) return;
    
    JLPhoto *photo = (JLPhoto *)self.photos[scrollView.tag];
    CGFloat photoY = (ScreenHeight-photo.frame.size.height)/2;
    CGRect photoF = photo.frame;
    
    if (photoY>0) {
        
        photoF.origin.y = photoY;
        
    }else{
        
        photoF.origin.y = 0;
        
    }
    
    photo.frame = photoF;
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    //如果结束缩放后scale为1时，跟原来的宽高会有些轻微的出入，导致无法滑动，需要将其调整为原来的宽度
    if (scale == 1.0) {
        
        CGSize tempSize = scrollView.contentSize;
        tempSize.width = ScreenWidth;
        scrollView.contentSize = tempSize;
        CGRect tempF = view.frame;
        tempF.size.width = ScreenWidth;
        view.frame = tempF;
        
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int currentIndex = scrollView.contentOffset.x/ScreenWidth;
    
    if (self.currentIndex!=currentIndex && scrollView.tag==bigScrollVIewTag) {
        
        self.currentIndex = currentIndex;
        
        for (UIView *view in scrollView.subviews) {
            
            if ([view isKindOfClass:[UIScrollView class]]) {
                
                UIScrollView *scrollView = (UIScrollView *)view;
                scrollView.zoomScale = 1.0;
            }
            
        }
        
    }
    
}

#pragma mark 设置frame

-(void)setFrame:(CGRect)frame{
    frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [super setFrame:frame];
}

#pragma mark - private

-(void)convertImageRects{
    
    for (JLPhoto *photo in self.photos) {
        
        UIImageView *sourceImageView = photo.sourceImageView;
        CGRect sourceF = [JLKeyWindow convertRect:sourceImageView.frame fromView:sourceImageView.superview];
        [self.sourceImageRects addObject:[NSValue valueWithCGRect:sourceF]];
        
    }
    
}

#pragma mark - JLPhotoBrowserOutputProtocol

- (void)setProgressViewVisibilityWithPhoto:(JLPhoto *)aPhoto visibility:(BOOL)visibility{
    self.progressViews[aPhoto.index].hidden = visibility;
}
    
- (void)setupProgress:(CGFloat)progress photo:(JLPhoto *)aPhoto{
    self.progressViews[aPhoto.index].progressValue = progress;
}
    
- (void)callbackImage:(UIImage *)image cacheType:(SDImageCacheType)cacheType aPhoto:(JLPhoto *)aPhoto{
    if (image!=nil) {
        
        self.progressViews[aPhoto.index].hidden = YES;
        
        //下载回来的图片
        if (cacheType==SDImageCacheTypeNone) {
            [self setupPhotoFrame:aPhoto];
        }else{
            aPhoto.frame = [self.sourceImageRects[aPhoto.index] CGRectValue];
            [UIView animateWithDuration:0.3 animations:^{
                [self setupPhotoFrame:aPhoto];
            }];
        }
    }else{
        
        //图片下载失败
        aPhoto.bounds = CGRectMake(0, 0, 240, 240);
        aPhoto.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
        aPhoto.contentMode = UIViewContentModeScaleAspectFit;
        aPhoto.image = [UIImage imageNamed:@"preview_image_failure"];
        
        [self.progressViews[aPhoto.index] removeFromSuperview];
    }
}
    
- (void)enlargeSmallScrollView:(UITapGestureRecognizer *)aTap{
    [UIView animateWithDuration:0.3 animations:^{
        
        UIScrollView *smallScrollView = (UIScrollView *)aTap.view.superview;
        smallScrollView.zoomScale = 3.0;
        
    }];
}

- (void)shrinkSmallScrollViewAndDismiss:(UITapGestureRecognizer *)aTap{
    //1.将图片缩放回一倍，然后再缩放回原来的frame，否则由于屏幕太小动画直接从3倍缩回去，看不完整
    JLPhoto *photo = (JLPhoto *)aTap.view;
    UIScrollView *smallScrollView = (UIScrollView *)photo.superview;
    smallScrollView.zoomScale = 1.0;
    
    //1.1如果是长图片先将其移动到CGPointMake(0, 0)在缩放回去
    if (CGRectGetHeight(photo.frame)>ScreenHeight) {
        smallScrollView.contentOffset = CGPointMake(0, 0);
    }
    
    //2.再取出原始frame，缩放回去
    CGRect frame = [self.sourceImageRects[photo.index] CGRectValue];
    
    [UIView animateWithDuration:0.3 animations:^{
        photo.frame = frame;
        self.blackView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dismissBrowser:(UITapGestureRecognizer *)aTap{
    [UIView animateWithDuration:0.3 animations:^{
        self.blackView.alpha = 0;
        aTap.view.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UI

- (void)setupViews{
    //0.创建黑色背景view
    [self setupBlackView];
    //1.创建bigScrollView
    [self setupBigScrollView];
}

-(void)setupBlackView{
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    blackView.backgroundColor = [UIColor blackColor];
    [self addSubview:blackView];
    self.blackView = blackView;
    
}

-(void)setupBigScrollView{
    
    UIScrollView *bigScrollView = [[UIScrollView alloc] init];
    bigScrollView.backgroundColor = [UIColor clearColor];
    bigScrollView.delegate = self;
    bigScrollView.tag = bigScrollVIewTag;
    bigScrollView.pagingEnabled = YES;
    bigScrollView.bounces = YES;
    bigScrollView.showsHorizontalScrollIndicator = NO;
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = 0;
    CGFloat scrollViewW = ScreenWidth;
    CGFloat scrollViewH = ScreenHeight;
    bigScrollView.frame = CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH);
    [self addSubview:bigScrollView];
    self.bigScrollView = bigScrollView;
    
    //3.设置滚动距离
    self.bigScrollView.contentSize = CGSizeMake(ScreenWidth*self.photos.count, 0);
    
    //开始滚动到当前的index
    self.bigScrollView.contentOffset = CGPointMake(ScreenWidth*self.currentIndex, 0);
    
}

- (void)dealloc{
    NSLog(@"browser dealloc");
}

@end
