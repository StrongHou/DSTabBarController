//
//  DSTabBarController.h
//  DSTabBarController
//
//  Created by houxq on 17/3/14.
//  Copyright © 2017年 houxq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DSTabBarController;

NS_INLINE void ds_exception(NSString *reason)
{
    @throw [NSException exceptionWithName:@"DSTabBarController" reason:reason userInfo:nil];
    
}


@protocol DSTabBarControllerDelegate <NSObject>

@optional

/*PublishButton*/
// TouchUpDown
- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldClickPublishButton:(UIButton *)button;
- (void)tabBarController:(DSTabBarController *)tabBarController didClickPublishButton:(UIButton *)button;

// LongPress
- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldLongPressPublishButton:(UIButton *)button;
- (void)tabBarController:(DSTabBarController *)tabBarController didLongPressPublishButton:(UIButton *)button;

/*TabBarButton*/
// TouchUpDown

- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldClickTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController;
- (void)tabBarController:(DSTabBarController *)tabBarController didClickTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController;

//
//// LongPress
- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldLongPressTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController;

- (void)tabBarController:(DSTabBarController *)tabBarController didLongPressUITabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController;

@end


@protocol DSTabBarControllerDataSource <NSObject>

@optional

- (UIButton *)tabBarControllerPublishButton:(DSTabBarController *)tabBarController;
- (NSUInteger)tabBarControllerPublishButtonIndex:(DSTabBarController *)tabBarController;

- (UIViewController *)tabBarControllerSelectPublishButtonViewController:(DSTabBarController *)tabBarController;


@end


@interface DSTabBarController : UITabBarController


- (instancetype)initTabBarControllerWithViewControllers:(NSArray *)viewController
                                                tabBarItems:(NSArray <UITabBarItem *>*)tabBarItems;

+ (instancetype)tabBarControllerWithViewControllers:(NSArray *)viewControllers
                                            tabBarItems:(NSArray <UITabBarItem *>*)tabBarItems;


@property (nullable, nonatomic, readonly, strong) UIButton *publishButton;

@property (nullable, nonatomic, readonly, strong) UIViewController *publishViewController;

@property (nonatomic, assign) CGFloat tabBarHeight;

@property (nonatomic, assign) CFTimeInterval minimumPressDuration;// Default is 1.2. Time in seconds the fingers must be held down for the gesture to be recognized >1


@property (nonatomic, assign, getter=isAutoPublishButtonLayout) BOOL autoPublishButtonLayout;  //Default is NO.

@property (nullable,nonatomic, assign) id <DSTabBarControllerDelegate> ds_delegate;

@property (nullable,nonatomic, assign) id <DSTabBarControllerDataSource> ds_dataSource;




- (UIViewController *)viewControllerWithItem:(UITabBarItem *)item;

@end

NS_ASSUME_NONNULL_END

