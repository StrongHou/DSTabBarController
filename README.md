# DSTabBarController
An easy-to-use TabBarController components

一个*tabBarController*（导航控制器）组件。简单易用，功能强大。轻量、低耦合以及良好的扩展性。


#### 普通的TabBar
如果你只想构建一个很普通的*tabbarController*，像这种：



![1.gif](http://upload-images.jianshu.io/upload_images/3101212-543b3976b4e0047c.gif?imageMogr2/auto-orient/strip)

那么你只需要这样做
````objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [self rootViewController1];
    [self.window makeKeyAndVisible];
    return YES;
}
// 设置导航控制器TabBarController
// 传入一个 `控制器数组` 和 `选项卡属性数组`
- (UIViewController *)rootViewController1
{
    
    NSArray *viewControllers = [self viewControllers];
    NSArray *tabBarItems = [self tabBarItems];
    DSTabBarController *tabBarController = [DSTabBarController tabBarControllerWithViewControllers:viewControllers tabBarItems:tabBarItems];
    return tabBarController;
}

// 这个数组是 每个选项卡上对应的控制器
// 可以传字符串、Class或者控制器实例
- (NSArray *)viewControllers
{
     UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:[[DSFirstTableViewController alloc] initWithStyle:UITableViewStylePlain] ];
    return @[nav1,@"DSSecondViewController"];
}
//这是数组是 每个选项卡的属性
//数组中每个元素的类型是 `UITabBarItem`
- (NSArray *)tabBarItems
{
    UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:@"one" image:[UIImage imageNamed:@"my"] selectedImage:[UIImage imageNamed:@"my_h"]];
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"two" image:[UIImage imageNamed:@"home"] selectedImage:[UIImage imageNamed:@"home_h"]];
    return @[tabBarItem1,tabBarItem2];
}
 ````
*DSTabBarController*提供了一个遵守*<DSTabBarControllerDelegate>*的代理**ds_delegate**。他可以监听选项卡（实际上是*UITabbarButton*）的**按下**和**长按**。

````objc
- (UIViewController *)rootViewController1
{
    NSArray *viewControllers = [self viewControllers];
    NSArray *tabBarItems = [self tabBarItems];
    DSTabBarController *tabBarController = [DSTabBarController tabBarControllerWithViewControllers:viewControllers tabBarItems:tabBarItems];
    //设置代理
    tabBarController.ds_delegate = self;
    return tabBarController;
}
````
实现代理方法
````objc
- (void)tabBarController:(DSTabBarController *)tabBarController didClickTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController
{
    [self addZoonAnimationWithView:tabBarButton];
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
````
上面代码是当选项卡点击后，给选项卡添加了一个帧动画。效果如下：

![2.gif](http://upload-images.jianshu.io/upload_images/3101212-fc92212fd36c7f52.gif?imageMogr2/auto-orient/strip)

当需要监听选项卡长按时，需要实现下面的代理方法
````objc
//tabBarController默认是不能响应长按事件的
//如果需要支持长按 这里返回YES
- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldLongPressTabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController
{
    return YES;
}
//这个方法里是写长按要实现的功能
- (void)tabBarController:(DSTabBarController *)tabBarController didLongPressUITabBarButton:(UIControl *)tabBarButton viewController:(UIViewController *)viewController
{
  //这里是长按功能的业务代码
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
````
设置后的效果如下：

![3.gif](http://upload-images.jianshu.io/upload_images/3101212-d05c886042e36e4f.gif?imageMogr2/auto-orient/strip)

你还可以设置长按的时间
````objc
@property (nonatomic, assign) CFTimeInterval minimumPressDuration;// Default is 0.8. Time in seconds the fingers must be held down for the gesture to be recognized 
````

### 特殊的TabBar
像是闲鱼客户端的那种TabBar，TarBar的中间有个特殊的按钮，大致效果如下：

![4.gif](http://upload-images.jianshu.io/upload_images/3101212-566c0e4a86bebc01.gif?imageMogr2/auto-orient/strip)

这就需要数据源方法了，首先设置数据源
````objc
 tabBarController.ds_dataSource = self;
````
实现以下的数据源方法
````objc
//设置特殊按钮
- (UIButton *)tabBarControllerPublishButton:(DSTabBarController *)tabBarController
{
  return [self publishButton];
}

- (UIButton *)publishButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"yuanfenqi"] forState:UIControlStateNormal];[button setImage:[UIImage imageNamed:@"yuanfenqi_h"] forState:UIControlStateSelected];
    button.backgroundColor =[UIColor cyanColor];
    //默认`sizeToFit`
    button.frame = CGRectMake(0, 0, 100, 100);
    button.showsTouchWhenHighlighted = YES;
    return button;
}
````
监听特殊按钮的点击
````objc
- (void)tabBarController:(DSTabBarController *)tabBarController didClickPublishButton:(UIButton *)button
{
    //添加关键帧动画
    [self addZoonAnimationWithView:button];
    //执行按钮点击后的事件
    //这里写你的业务逻辑代码
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor =[UIColor yellowColor];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.view.alpha = 0.9;
    [tabBarController.selectedViewController presentViewController:vc animated:YES completion:nil];
}
````
##### 关于特殊按钮的位置
若需要指定特殊按钮的位置，实现以下数据源方法
````objc
- (NSUInteger)tabBarControllerPublishButtonIndex:(DSTabBarController *)tabBarController
{
    return 1;
}
````
若没有指定特殊按钮的位置，有如下简单的规则：
>如果TabBar上总选项卡个数是**奇数**个，则特殊按钮**居中**;
如果TabBar上总选项卡个数是**偶数**个,特殊按钮会在**最后**一个位置。

如果你的应用点击特殊按钮不是弹出一个单独的控制器，而是根TabBar上的其他选项卡一样，需要实现以下数据源方法
````objc
- (UIViewController *)tabBarControllerSelectPublishButtonViewController:(DSTabBarController *)tabBarController
{
    UIViewController *vc= [[UIViewController alloc] init];
    vc.title  = @"Text";
    vc.view.backgroundColor = [UIColor yellowColor];
    return [[UINavigationController alloc] initWithRootViewController:vc];
}
````
效果如下图：

![5.gif](http://upload-images.jianshu.io/upload_images/3101212-7e2312b738e31eb3.gif?imageMogr2/auto-orient/strip)

监听特殊按钮的长按
````objc
- (BOOL)tabBarController:(DSTabBarController *)tabBarController shouldLongPressPublishButton:(UIButton *)button
{
    return YES;
}

//这个方法里是写长按要实现的功能
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
````

支持Pod：**Pod  'DSTabBarController'**
