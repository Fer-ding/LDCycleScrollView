//
//  LDCycleScrollView.m
//  OOLaGongYi
//
//  Created by YueHui on 16/12/30.
//  Copyright © 2016年 GZ Leihou Software Development CO.,LTD. All rights reserved.
//

#import "LDCycleScrollView.h"

@interface LDCycleScrollView () <UIScrollViewDelegate>

//当UI控件添加到父控件中以后，父控件的subViews数组会有强指针指向这个对象，就可以保证这个对象不会被销毁，在搞一个属性引用这个对象，用弱引用就可以
@property (assign, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) UIImageView *leftImageView;
@property (assign, nonatomic) UIImageView *centerImageView;
@property (assign, nonatomic) UIImageView *rightImageView;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger totalPage;
@property (assign, nonatomic) NSInteger currentPage;

@end

@implementation LDCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self setupUI];
    [self setupConfigration];
    
    return self;
}

- (void)setupUI {
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView = scrollView;
    
    UIImageView *leftImageView = [[UIImageView alloc] init];
    self.leftImageView = leftImageView;
    UIImageView *centerImageView = [[UIImageView alloc] init];
    self.centerImageView = centerImageView;
    UIImageView *rightImageView = [[UIImageView alloc] init];
    self.rightImageView = rightImageView;

    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.centerImageView];
    [self.scrollView addSubview:self.rightImageView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.offset(0);
        make.width.equalTo(self);
        make.height.equalTo(self);
    }];
    
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.left.equalTo(self.leftImageView.mas_right);
        make.width.equalTo(self);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.offset(0);
        make.left.equalTo(self.centerImageView.mas_right);
        make.width.equalTo(self);
    }];

}

- (void)setupConfigration {
    
    self.timeInterval = 3.0;
    self.currentPage = 0;
}

- (void)didMoveToSuperview
{
    [self startTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0.0);
    });
}

#pragma mark - setter
- (void)setPageControlShowStyle:(UIPageControlShowStyle)pageControlShowStyle {
    
    if (pageControlShowStyle == UIPageControlShowStyleNone) {
        return;
    }
    
    _pageControl = [[UIPageControl alloc]init];
    _pageControl.numberOfPages = self.imageNameArray.count;
    _pageControl.currentPage = 0;
    _pageControl.enabled = NO;
    [self addSubview:_pageControl];
    
    if (pageControlShowStyle == UIPageControlShowStyleLeft)
    {
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(12);
            make.bottom.offset(0);
        }];
    }
    else if (pageControlShowStyle == UIPageControlShowStyleCenter)
    {
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.offset(0);
        }];
    }
    else
    {
        [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-12);
            make.bottom.offset(0);
        }];
    }
}

- (void)setImageNameArray:(NSArray *)imageNameArray {
    _imageNameArray = imageNameArray;
    
    NSParameterAssert(_imageNameArray.count);
    
    self.pageControl.numberOfPages = self.totalPage = _imageNameArray.count;
}

- (void)setImageUrlArray:(NSArray *)imageUrlArray {
    _imageUrlArray = imageUrlArray;
    
    NSParameterAssert(_imageUrlArray.count);
    
    self.pageControl.numberOfPages = self.totalPage = _imageUrlArray.count;
}

#pragma mark - Timer

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(nextPicture) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)nextPicture {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + self.scrollView.frame.size.width, 0) animated:YES];
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:nil afterDelay:0.4];
}

#pragma mark - Private

- (void)updatePicture {
    /**
     *  计算left，right的图片在数组中的index。
     * 1、当currentPage == 0时，left的index为array的最后一张，index = (currentPage - 1 + totalPage) % totalPage。
     * 2、当currentPage == array.count - 1时，right的index为array的第一张，index = (currentPage + 1) % totalPage。
     * 3、当0 < currentpage < array.count - 1时,index = (currentPage + 1) % totalPage。
     **/
    if (self.imageUrlArray.count) {
        [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrlArray[(self.currentPage + self.totalPage - 1) % self.totalPage]] placeholderImage:self.placeHolderImage];
        [self.centerImageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrlArray[self.currentPage]] placeholderImage:self.placeHolderImage];
        [self.rightImageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrlArray[(self.currentPage + 1) % self.totalPage]] placeholderImage:self.placeHolderImage];
    }
    else if (self.imageNameArray.count) {
        self.leftImageView.image = [UIImage imageNamed:self.imageNameArray[(self.currentPage + self.totalPage - 1) % self.totalPage]];
        self.centerImageView.image = [UIImage imageNamed:self.imageNameArray[self.currentPage]];
        self.rightImageView.image = [UIImage imageNamed:self.imageNameArray[(self.currentPage + 1) % self.totalPage]];
    }

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    if (page == 0) {    // 上一张
        self.currentPage = (self.currentPage + self.totalPage - 1) % self.totalPage;
    }
    else if (page == 2) {    // 下一张
        self.currentPage = (self.currentPage + 1) % self.totalPage;
    }
    else {    // 不变
        return;
    }
    
    [self updatePicture];
    self.pageControl.currentPage = self.currentPage;
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0.0);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

@end
