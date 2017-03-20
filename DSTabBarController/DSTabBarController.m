//
//  DSTabBarController.m
//  DSTabBarController
//
//  Created by houxq on 17/3/14.
//  Copyright © 2017年 houxq. All rights reserved.
//

#import "DSTabBarController.h"
#import "DSTabBar.h"


@interface DSTabBarController ()  <DSTabBarDelegate,UITabBarControllerDelegate>

@property (nonatomic, readwrite, strong) UIViewController *publishViewController;
@property (nonatomic, copy) NSArray *ds_viewControllers;
@property (nonatomic, copy) NSArray *tabBarItems;
@property (nonatomic, assign) NSUInteger publishBtnIndex;
@property (nonatomic, readwrite, strong) UIButton *publishButton;

@end

@implementation DSTabBarController

#pragma mark -life cycle

- (instancetype)initTabBarControllerWithViewControllers:(NSArray *)viewController tabBarItems:(NSArray<UITabBarItem *> *)tabBarItems
{
    self = [super init];
    if(self) {
        
        self.tabBarItems = tabBarItems;
        self.ds_viewControllers = viewController;
        self.publishBtnIndex = NSNotFound;
        
    }
    return self;
}

+ (instancetype)tabBarControllerWithViewControllers:(NSArray *)viewControllers tabBarItems:(NSArray<UITabBarItem *> *)tabBarItems
{
    return [[self alloc] initTabBarControllerWithViewControllers:viewControllers tabBarItems:tabBarItems];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self setUpTabBar];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    [self.tabBar layoutSubviews];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self setChildControllerWithViewControlles:self.ds_viewControllers];
    [self setPublishButtonInfo];
   

}
#pragma makr - publish method

- (UIViewController *)viewControllerWithItem:(UITabBarItem *)item {

    UIViewController *viewController = nil;
    for(UIViewController *vc in self.viewControllers){
        
        if([vc.tabBarItem isEqual:item] &&
            vc.tabBarItem == item){
            viewController = vc;
        }
    }
    return viewController;
}

#pragma mark - private method

- (void)setChildControllerWithViewControlles:(NSArray *)ds_viewControllers
{
    NSUInteger tabBarItemsCount = self.tabBarItems.count;
    NSUInteger ds_viewControllerCount = ds_viewControllers.count;
    if(tabBarItemsCount != ds_viewControllerCount) {
        
        ds_exception(@"调用initTabBarControllerWithViewControllers:tabBarItems:或者tabBarControllerWithViewControllers:tabBarItems:方法需保证传入两个数组个数相同");
    }
     self.publishBtnIndex = [self publishButtonIndexWithCount:self.ds_viewControllers.count];
    _ds_viewControllers = [self viewControllerFromCustomerArray:ds_viewControllers];
   
}

- (UIViewController *)viewControllerWithObject:(id)object
{
    UIViewController *viewController = nil;
    if([object isKindOfClass:[UIViewController class]]){
        // object is a UIViewController instance
        viewController = object;
    
    }else if([object isKindOfClass:[NSString class]]){
        // object is NSString
        Class class = NSClassFromString(object);
        if(class){
            viewController = [[class alloc] init];
        }else{
            ds_exception([NSString stringWithFormat:@"控制器数组中`%@` 参数错误",object]);
        }
        
    }else if([[object class] isKindOfClass:[UIViewController class]]){
        // object is class
        viewController = [[object alloc] init];
    }
    if(!viewController){
        
        ds_exception([NSString stringWithFormat:@"请检查您传入的控制器数组参数 :`%@`",object]);
    }
  
    return viewController;
}

- (NSArray *)viewControllerFromCustomerArray:(NSArray *)customerArray
{
    
    __block NSMutableArray *array = [NSMutableArray array];
    __block UIViewController *subViewController = nil;
    __block UITabBarItem *item = nil;
    
    BOOL isExistPublishViewControllr = self.publishViewController != nil;
    if(isExistPublishViewControllr){
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.ds_viewControllers];
        [tempArray  insertObject:self.publishViewController atIndex:self.publishBtnIndex];
        customerArray = [tempArray copy];
        
        NSMutableArray *tempItemArray =[NSMutableArray arrayWithArray:self.tabBarItems];
        [tempItemArray insertObject:[UITabBarItem new] atIndex:self.publishBtnIndex];
        _tabBarItems = [tempItemArray copy];
    }
    [customerArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        item = self.tabBarItems[idx];
        subViewController = [self viewControllerWithObject:obj];
        [self addChildViewController:subViewController];
        [array addObject:subViewController];
        subViewController.tabBarItem = item;
        
       }];
    return [array copy];
}

//PublishButtonIndex
- (NSUInteger)publishButtonIndexWithCount:(NSUInteger)count
{
    
    if(!self.publishButton) return NSNotFound;
    NSUInteger index = count%2 == 0 ? count/2 :count;
    if([self.ds_dataSource respondsToSelector:@selector(tabBarControllerPublishButtonIndex:)]){
        
        NSUInteger tempIndex = NSNotFound;
        tempIndex = [self.ds_dataSource tabBarControllerPublishButtonIndex:self];
        index = tempIndex >= count?count:tempIndex;
    
    }
    return index;
}

- (void)setUpTabBar
{
    //KVC
    [self setValue:[[DSTabBar alloc] init] forKey:NSStringFromSelector(@selector(tabBar))];
    self.ds_tabBar.ds_delegate = self;
    self.minimumPressDuration = 1.2;
    self.delegate = self;
}


- (void)setPublishButtonInfo
{
    if(!self.publishButton) return;
    [self.ds_tabBar setPublishButton:self.publishButton index:self.publishBtnIndex viewController:self.publishViewController];
}


- (void)addPublishButtonControllerView
{
    if(!self.publishViewController) return;
    UIViewController *currentViewController = self.selectedViewController;
    if(currentViewController &&
       currentViewController !=  self.publishViewController){
        
        self.selectedViewController = self.publishViewController;
    }
}

#pragma mark - <DSTabBarDelegate>

- (void)tabBar:(UITabBar *)tabBar didLongPressItem:(UITabBarItem *)item
{
    DSTabBar *ds_tabBar = (DSTabBar *)tabBar;
    BOOL canLongPress =NO;
    UIViewController *viewController = [self viewControllerWithItem:item];

    UIControl *control = [ds_tabBar tabBarButtonWithItem:item];
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:shouldLongPressTabBarButton:viewController:)])
    {
        canLongPress =  [self.ds_delegate tabBarController:self shouldLongPressTabBarButton:control
                       viewController:viewController];
    }
    
   
    if(!canLongPress) return;
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:didLongPressUITabBarButton:viewController:)]){
        
        [self.ds_delegate tabBarController:self didLongPressUITabBarButton:control viewController:viewController];
    }
}

- (void)tabBar:(DSTabBar *)tabBar didSelectPublishButton:(UIButton *)publishButton {

    BOOL canSelect = YES;
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:shouldClickPublishButton:)]){
        
        canSelect = [self.ds_delegate tabBarController:self shouldClickPublishButton:publishButton];
    }
    if(!canSelect) return;
    
    [self addPublishButtonControllerView];
    
    publishButton.selected = YES;
    
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:didClickPublishButton:)]){
        
        [self.ds_delegate tabBarController:self didClickPublishButton:publishButton];
    }
}

- (void)tabBar:(DSTabBar *)tabBar didLongPressPublishButton:(UIButton *)publishButton
{
    BOOL canLongPress = NO;
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:shouldLongPressPublishButton:)]){
        
        canLongPress = [self.ds_delegate tabBarController:self shouldLongPressPublishButton:publishButton];
    }
    if(!canLongPress) return;
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:didLongPressPublishButton:)]){
        
        [self.ds_delegate tabBarController:self didLongPressPublishButton:publishButton];
    }
}

#pragma mark -  <UITabBarControllerDelegate>


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    
}

- (void)tabBar:(UITabBar *)tabBar willBeginCustomizingItems:(NSArray<UITabBarItem *> *)items
{
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{

    UIControl *control = [self.ds_tabBar tabBarButtonWithItem:viewController.tabBarItem];
    BOOL canSelect =YES;
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:shouldClickTabBarButton:viewController:)])
    {
        canSelect = [self.ds_delegate tabBarController:self shouldClickTabBarButton:control viewController:viewController];
    }
    return canSelect;

}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
    
    self.publishButton.selected = NO;
    if([self.ds_delegate respondsToSelector:@selector(tabBarController:didClickTabBarButton:viewController:)]){
        
        [self.ds_delegate tabBarController:self didClickTabBarButton:[self.ds_tabBar tabBarButtonWithItem:viewController.tabBarItem] viewController:viewController];
    }
    
}

#pragma mark - getter and setter
- (DSTabBar *)ds_tabBar
{
    return (DSTabBar *)self.tabBar;
    
}
- (UIButton *)publishButton {
    
    if(_publishButton == nil){
        
        if([self.ds_dataSource respondsToSelector:@selector(tabBarControllerPublishButton:)]){
            
            _publishButton = [self.ds_dataSource tabBarControllerPublishButton:self];
            
        }
    }
    return _publishButton;
}

- (UIViewController *)publishViewController {

    if(_publishViewController == nil){
        
        if(!self.publishButton) return nil;
        if([self.ds_dataSource respondsToSelector:@selector(tabBarControllerSelectPublishButtonViewController:)]){
        
            _publishViewController = [self.ds_dataSource tabBarControllerSelectPublishButtonViewController:self];
        }
    
    }
    return _publishViewController;
}




- (void)setMinimumPressDuration:(CFTimeInterval)minimumPressDuration
{
     minimumPressDuration = minimumPressDuration>=1?minimumPressDuration:1;
    _minimumPressDuration = minimumPressDuration;
    self.ds_tabBar.minimumPressDuration = minimumPressDuration;
}


- (void)setTabBarHeight:(CGFloat)tabBarHeight {
    
    _tabBarHeight = tabBarHeight;
    if(self.tabBarHeight){
        
        CGFloat height = self.tabBar.frame.size.height;
        
        self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y+(height -self.tabBarHeight), self.tabBar.frame.size.width, self.tabBarHeight);
    }
}



@end


