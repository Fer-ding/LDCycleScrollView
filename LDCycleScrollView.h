//
//  LDCycleScrollView.h
//  OOLaGongYi
//
//  Created by YueHui on 16/12/30.
//  Copyright © 2016年 GZ Leihou Software Development CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIPageControlShowStyle)
{
    UIPageControlShowStyleNone,//default
    UIPageControlShowStyleLeft,
    UIPageControlShowStyleCenter,
    UIPageControlShowStyleRight,
};

@protocol LDCycleScrollViewDelegate;

@interface LDCycleScrollView : UIView

@property (nonatomic, weak) id<LDCycleScrollViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIPageControl *pageControl;

@property (nonatomic, copy) NSArray *imageNameArray;
@property (nonatomic, copy) NSArray *imageUrlArray;
@property (nonatomic, assign) UIPageControlShowStyle pageControlShowStyle;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, assign) NSTimeInterval timeInterval;

@end

@protocol LDCycleScrollViewDelegate <NSObject>

@optional
- (void)selectItemAtIndex:(NSInteger)index;

@end
