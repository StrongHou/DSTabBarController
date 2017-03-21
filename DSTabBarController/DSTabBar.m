//
//  DSTabBar.m
//  DSTabBarController
//
//  Created by houxq on 17/3/14.
//  Copyright © 2017年 houxq. All rights reserved.
//

#import "DSTabBar.h"

static const NSTimeInterval timerStep_ = 0.1f;

@interface DSTabBar () <UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSArray *tabBarButtonArray;
@property (nonatomic, copy) NSArray *ds_items;
@property (nonatomic, strong) UIButton *publishBtn;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, weak) UIViewController *publishViewController;


//longPress
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, weak) UIControl *currentControl;

@end

@implementation DSTabBar
#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumPressDuration = 0.8f;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self setPublishButtonFrame];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if(!self.publishBtn) return [super hitTest:point withEvent:event];
    if(self.hidden ||
       (self.alpha <= 0.01f) ||
       (self.userInteractionEnabled == NO)) {
        
        return [super hitTest:point withEvent:event];
    }
    if (CGRectContainsPoint(self.publishBtn.frame, point)) {
        
        return self.publishBtn;
    }
    return [super hitTest:point withEvent:event];
}


#pragma mark - event response
- (void)buttonToucBegin:(UIControl *)control
{
    self.currentTime = 0;
    self.currentControl = control;
    [self startTimer];
    if(control == self.publishBtn){
        if([self.ds_delegate respondsToSelector:@selector(tabBar:didSelectPublishButton:)]){
            
            [self.ds_delegate tabBar:self didSelectPublishButton:self.publishBtn];
        }
    }
}

- (void)buttonTouchEnd:(UIControl *)control
{
    self.currentTime = 0;
    [self endTimer];
}

#pragma mark - publish method
- (void)setPublishButton:(UIButton *)publishBtn index:(NSUInteger)index viewController:(UIViewController *)viewController
{
    
    self.index = index;
    self.publishBtn = publishBtn;
    self.publishViewController = viewController;
    if(self.publishBtn){
         [self configPublishButton];
    }
}

- (UIControl *)tabBarButtonWithItem:(UITabBarItem *)item {

    NSUInteger index = [self.ds_items indexOfObject:item];
    if(index == NSNotFound) return nil;
    return self.tabBarButtonArray[index];
}

- (UITabBarItem *)tabBarItemWithTabBarButton:(UIView *)tabBarButton {

    NSUInteger index = [self.tabBarButtonArray indexOfObject:tabBarButton];
    if(index == NSNotFound) return nil;
    return self.ds_items[index];

}

#pragma mark - private method
- (void)setPublishButtonFrame
{
    
    self.ds_items = self.items;
    NSArray *sortArray = [self sortedSubviewWithSuperView:self];
    self.tabBarButtonArray = [self tabBarButtonArrayWithArray:sortArray];
    NSUInteger tabBarButtonCount = self.tabBarButtonArray.count;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat publishBtnW = self.publishBtn.frame.size.width;
    CGFloat publishBtnH = self.publishBtn.frame.size.height >= height? self.publishBtn.frame.size.height:height;
    
    CGFloat tabBarBtnW = (width - publishBtnW)/tabBarButtonCount;
    CGFloat tabBarBTnH =  height;
    
    CGFloat tabBarBtnX= 0;
    CGFloat tabBarBtnY = 0;
    
    __block CGFloat offset = 0;
    [self.tabBarButtonArray enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //long press event
        [self addLongPressEvent:obj];
        //set subViews Frame
        if(self.publishBtn ){
            offset = idx >= self.index?publishBtnW:0;
            obj.frame = CGRectMake(tabBarBtnX+tabBarBtnW*idx+offset, tabBarBtnY, tabBarBtnW, tabBarBTnH);
        }
        
    }];
    if(self.publishBtn){
    
        self.publishBtn.frame = CGRectMake(tabBarBtnX+self.index*tabBarBtnW, height -publishBtnH, publishBtnW, publishBtnH);
        [self bringSubviewToFront:self.publishBtn];
    }
}

- (void)addLongPressEvent:(UIControl *)control
{
    
    [control addTarget:self action:@selector(buttonToucBegin:) forControlEvents:UIControlEventTouchDown];
    [control addTarget:self action:@selector(buttonTouchEnd:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    
}

- (void)configPublishButton
{
    //remove Target
    NSSet *allTargets = self.publishBtn.allTargets;
    [allTargets enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.publishBtn removeTarget:obj action:NULL forControlEvents:UIControlEventTouchUpInside];
        
    }];
    self.publishBtn.adjustsImageWhenHighlighted = NO;
    UIImage *image = [self.publishBtn imageForState:UIControlStateSelected];
    if(image){
        [self.publishBtn setImage:image forState:UIControlStateHighlighted | UIControlStateSelected];
    }
    //addTarget
    [self addLongPressEvent:self.publishBtn];
    [self addSubview:self.publishBtn];
    if( self.frame.size.width == 0 &&
       self.frame.size.height == 0){
        [self.publishBtn sizeToFit];
    }

}

- (void)startTimer
{
    [self endTimer];
    self.timer  = [NSTimer scheduledTimerWithTimeInterval:timerStep_ target:self selector:@selector(handerTimer) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)endTimer
{
    if(self.timer){
        
        [self.timer invalidate];
        self.timer = nil;
    }
}


- (void)handerTimer
{
    self.currentTime += timerStep_;
    if(self.currentTime >= self.minimumPressDuration){
        
        [self endTimer];
        if(self.currentControl == self.publishBtn){
            
            if([self.ds_delegate respondsToSelector:@selector(tabBar:didLongPressPublishButton:)]){
            
                [self.ds_delegate tabBar:self didLongPressPublishButton:self.publishBtn];
            
            }
            
        }else{
            if([self.ds_delegate respondsToSelector:@selector(tabBar:didLongPressItem:)]){
                
                [self.ds_delegate tabBar:self didLongPressItem: [self tabBarItemWithTabBarButton:self.currentControl]];
            }
            
        }
    }
}


- (NSArray *)tabBarButtonArrayWithArray:(NSArray *)array {
    
    NSMutableArray *tabBarButtonMutableArray = [NSMutableArray arrayWithCapacity:array.count - 1];
    [array enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            [tabBarButtonMutableArray addObject:obj];
            
        }
    }];
    
    if(self.publishViewController && tabBarButtonMutableArray.count> self.index){
        
        [tabBarButtonMutableArray removeObjectAtIndex:self.index];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.ds_items];
        [tempArray removeObjectAtIndex:self.index];
        self.ds_items = [tempArray copy];
    }
    
    return [tabBarButtonMutableArray copy];
    
}

- (NSArray *)sortedSubviewWithSuperView:(UIView *)superView {
    NSArray *sortedSubviews = [superView.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView * formerView, UIView * latterView) {
        CGFloat formerViewX = formerView.frame.origin.x;
        CGFloat latterViewX = latterView.frame.origin.x;
        return  (formerViewX > latterViewX) ? NSOrderedDescending : NSOrderedAscending;
    }];
    return sortedSubviews;
}

@end


