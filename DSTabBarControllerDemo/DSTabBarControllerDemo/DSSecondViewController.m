//
//  DSSecondViewController.m
//  DSTabBarControllerDemo
//
//  Created by houxq on 17/3/20.
//  Copyright © 2017年 houxq. All rights reserved.
//

#import "DSSecondViewController.h"

@interface DSSecondViewController ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation DSSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.label];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.tabBarItem.badgeValue  = @"3";

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.label.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UILabel *)label {

    if(_label == nil){
        
        _label = [[UILabel alloc] init];
        _label.text = @"Hello,World!";
        _label.textColor  =[UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}
@end
