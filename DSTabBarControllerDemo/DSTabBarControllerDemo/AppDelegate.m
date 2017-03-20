//
//  AppDelegate.m
//  DSTabBarControllerDemo
//
//  Created by houxq on 17/3/20.
//  Copyright © 2017年 houxq. All rights reserved.
//

#import "AppDelegate.h"
#import "DSTabBarController.h"
#import "DSFirstTableViewController.h"
#import "DSSecondViewController.h"


@interface AppDelegate () <DSTabBarControllerDelegate,DSTabBarControllerDataSource>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.window makeKeyAndVisible];
  
    self.window.rootViewController = [self rootViewController1];
    
    return YES;
}




- (UIViewController *)rootViewController1
{
    
    NSArray *viewControllers = [self viewControllers];
    
    NSArray *tabBarItems = [self tabBarItems];
    
    DSTabBarController *tabBarController = [DSTabBarController tabBarControllerWithViewControllers:viewControllers tabBarItems:tabBarItems];
    
    tabBarController.ds_dataSource = self ;
    tabBarController.ds_delegate = self;
    
    return tabBarController;
}





- (NSArray *)viewControllers
{
    
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:[[DSFirstTableViewController alloc] initWithStyle:UITableViewStylePlain] ];
    
    
    return @[nav1,@"DSSecondViewController"];
}

- (NSArray *)tabBarItems
{

    UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"one" image:[UIImage imageNamed:@"my"] selectedImage:[UIImage imageNamed:@"my_h"]];
    
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"two" image:[UIImage imageNamed:@"home"] selectedImage:[UIImage imageNamed:@"home_h"]];
    
    return @[tabBarItem1,tabBarItem2];
}

- (void)addZoonAnimationWithView:(UIView *)view
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
    animation.duration = 0.9;
    animation.calculationMode = kCAAnimationCubic;
    [view.layer addAnimation:animation forKey:nil];
}

- (UIButton *)publishButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:[UIImage imageNamed:@"yuanfenqi"] forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:@"yuanfenqi_h"] forState:UIControlStateSelected];
    
    button.backgroundColor =[UIColor cyanColor];
    
    button.frame = CGRectMake(0, 0, 100, 100);
    
    button.showsTouchWhenHighlighted = YES;
    
    return button;
}


#pragma mark - <DSTabBarControllerDelegate,DSTabBarControllerDataSource>


// default is YES
- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldClickTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController
{

    return YES;
}



// You can get the tabBarButton which you clicked
- (void)tabBarController:(DSTabBarController *)tabBarController didClickTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController
{
    [self addZoonAnimationWithView:tabBarButton];

}

- (void)tabBarController:(DSTabBarController *)tabBarController didLongPressUITabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController
{

    
    [UIView animateWithDuration:0.25 animations:^{
        viewController.view.layer.transform = CATransform3DMakeScale(0.95, 0.95, 0.7);
    }];
    
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"title" message:@"message" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [UIView animateWithDuration:0.25 animations:^{
            viewController.view.layer.transform = CATransform3DIdentity;
        }];
        
    }];
    
    [alerController addAction:action];
    
    [viewController presentViewController:alerController animated:YES completion:nil];
}


- (void)tabBarController:(DSTabBarController *)tabBarController didClickPublishButton:(UIButton *)button
{
    [self addZoonAnimationWithView:button];

}



//
- (UIButton *)tabBarControllerPublishButton:(DSTabBarController *)tabBarController
{

    return [self publishButton];
}


- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldLongPressPublishButton:(UIButton *)button
{
    return YES;
}

- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldLongPressTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController
{
    return YES;
}


- (void)tabBarController:(DSTabBarController *)tabBarController didLongPressPublishButton:(UIButton *)button
{
    
    UIViewController *viewController = tabBarController.publishViewController;
    
    [UIView animateWithDuration:0.25 animations:^{
        viewController.view.layer.transform = CATransform3DMakeScale(0.95, 0.95, 0.7);
    }];
    
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"title" message:@"message" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [UIView animateWithDuration:0.25 animations:^{
            viewController.view.layer.transform = CATransform3DIdentity;
        }];
        
    }];
    
    [alerController addAction:action];
    
    [viewController presentViewController:alerController animated:YES completion:nil];

}

- (UIViewController *)tabBarControllerSelectPublishButtonViewController:(DSTabBarController *)tabBarController
{

    UIViewController *vc= [[UIViewController alloc] init];
    vc.title  = @"Text";
    vc.view.backgroundColor = [UIColor yellowColor];
    
    return [[UINavigationController alloc] initWithRootViewController:vc];

}
@end
