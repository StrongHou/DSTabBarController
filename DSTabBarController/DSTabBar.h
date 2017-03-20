//
//  DSTabBar.h
//  DSTabBarController
//
//  Created by houxq on 17/3/14.
//  Copyright © 2017年 houxq. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DSTabBar;

@protocol DSTabBarDelegate  <NSObject>

- (void)tabBar:(DSTabBar *)tabBar didLongPressItem:(UITabBarItem *)item;
- (void)tabBar:(DSTabBar *)tabBar didSelectPublishButton:(UIButton *)publishButton;
- (void)tabBar:(DSTabBar *)tabBar didLongPressPublishButton:(UIButton *)publishButton;

@end



@interface DSTabBar : UITabBar



@property (nonatomic, assign) id <DSTabBarDelegate>ds_delegate;


@property (nonatomic, assign, readonly) NSUInteger index;

- (void)setPublishButton:(UIButton *)publishBtn index:(NSUInteger)index viewController:(UIViewController *)viewController;

- (UIControl *)tabBarButtonWithItem:(UITabBarItem *)item;

@property (nonatomic, assign) CFTimeInterval minimumPressDuration;
@end
