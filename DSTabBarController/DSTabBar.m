//
//  DSTabBar.m
//  DSTabBarController
//
//  Created by houxq on 17/3/14.
//  Copyright © 2017年 houxq. All rights reserved.
//

#import "DSTabBar.h"

@interface DSTabBar () <UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSArray *tabBarButtonArray;
@property (nonatomic, copy) NSArray *ds_items;
@property (nonatomic, strong) UIButton *publishBtn;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, weak) UIViewController *publishViewController;

@end



@implementation DSTabBar


#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.minimumPressDuration = 0.5;
        
        [self addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}




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
        
//        long press event
        [self setTabBarButtonLongPressEvent:obj];
        //set subViews Frame
        if(self.publishBtn ){
            offset = idx >= self.index?publishBtnW:0;
            obj.frame = CGRectMake(tabBarBtnX+tabBarBtnW*idx+offset, tabBarBtnY, tabBarBtnW, tabBarBTnH);
            }
        
    }];
    self.publishBtn.frame = CGRectMake(tabBarBtnX+self.index*tabBarBtnW, height -publishBtnH, publishBtnW, publishBtnH);

}


- (void)setTabBarButtonLongPressEvent:(UIControl *)view
{   
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tabBarButtonLongPress:)];
    longPress.minimumPressDuration = self.minimumPressDuration;
    longPress.delegate = self;
    [view addGestureRecognizer:longPress];
    
    
}

- (void)offsetButtonTouchEnd:(UIControl *)control
{

    
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

#pragma mark - private 

- (NSUInteger)removeWithItem:(UITabBarItem *)tabBarItem
{
    NSMutableArray <UITabBarItem *> *tempArray = [NSMutableArray array];
    __block NSUInteger index = NSNotFound;
    [self.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![tabBarItem isEqual:obj]){
        
            [tempArray addObject:obj];
        }else {
            index = idx;
        }
    }];
    self.ds_items = tempArray;
    return index;
}


#pragma mark - event response

- (void)tabBarButtonLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        UIView *control = gestureRecognizer.view;
       
        if([self.ds_delegate respondsToSelector:@selector(tabBar:didLongPressItem:)]){
        
            [self.ds_delegate tabBar:self didLongPressItem: [self tabBarItemWithTabBarButton:control]];
            
        }
    }
}

- (void)publishBtnDidClick:(UIButton *)sender
{
    
    if([self.ds_delegate respondsToSelector:@selector(tabBar:didSelectPublishButton:)]){
        
        [self.ds_delegate tabBar:self didSelectPublishButton:sender];
        
    }
}

- (void)publishBtnlongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
       
        if([self.ds_delegate respondsToSelector:@selector(tabBar:didLongPressPublishButton:)]){
    
            [self.ds_delegate tabBar:self didLongPressPublishButton:self.publishBtn];
        }
    }
}


#pragma mark - publish method
- (void)setPublishButton:(UIButton *)publishBtn index:(NSUInteger)index viewController:(UIViewController *)viewController
{
    
    self.index = index;
    self.publishBtn = publishBtn;
    self.publishViewController = viewController;
    NSSet *allTargets = publishBtn.allTargets;
    
    [allTargets enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [publishBtn removeTarget:obj action:NULL forControlEvents:UIControlEventTouchUpInside];
       
    }];
    
    publishBtn.adjustsImageWhenHighlighted = NO;
    UIImage *image = [publishBtn imageForState:UIControlStateSelected];
    if(image){
         [publishBtn setImage:image forState:UIControlStateHighlighted | UIControlStateSelected];
    }
       // UIControlEventTouchUpInside
    [publishBtn addTarget:self action:@selector(publishBtnDidClick:) forControlEvents:UIControlEventTouchDown];
    
    //longPress
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(publishBtnlongPress:)];
    longPress.minimumPressDuration = self.minimumPressDuration;
    longPress.numberOfTouchesRequired = 1;
    [publishBtn addGestureRecognizer:longPress];
    [self addSubview:publishBtn];
    if( self.frame.size.width == 0 &&
        self.frame.size.height == 0){
         [self.publishBtn sizeToFit];
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

- (NSArray *)removeOtherTabBarButtonWithArray:(NSArray *)allTabBarController
{

    if(!self.publishViewController) return allTabBarController;
    
    NSUInteger index = [self removeWithItem:self.publishViewController.tabBarItem];
    
    if(index == NSNotFound) return allTabBarController;
    
    NSMutableArray *array = [NSMutableArray array];
    
    [allTabBarController enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(idx !=index){
            [array addObject:obj];
        }
    }];
    return [array copy];
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

- (NSArray *)sortedSubviewWithSuperView:(UIView *)superView {
    NSArray *sortedSubviews = [superView.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView * formerView, UIView * latterView) {
        CGFloat formerViewX = formerView.frame.origin.x;
        CGFloat latterViewX = latterView.frame.origin.x;
        return  (formerViewX > latterViewX) ? NSOrderedDescending : NSOrderedAscending;
    }];
    return sortedSubviews;
}




@end


