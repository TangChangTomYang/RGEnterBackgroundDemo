//
//  AppDelegate.m
//  RGEnterBackgroundDemo
//
//  Created by yangrui on 2019/2/26.
//  Copyright © 2019年 yangrui. All rights reserved.
//

#import "AppDelegate.h"
#import "RGLogTool.h"

// 能容忍 进入后台最长时长
#define EnterBGround_MaxTimeInterval   150

@interface AppDelegate ()

/**
 app 进入后台倒计时器, 必须在倒计时后必须强制保存app 状态以便, App 进入前台恢复
 */
@property(nonatomic, strong)NSTimer *enterBackGroundTimer;
/**
 额外时间任务id
 */
@property(nonatomic, assign)UIBackgroundTaskIdentifier bgTaskId;
/**
app进入后台后,是否成功保存了app之前的状态
 */
@property(nonatomic, assign)BOOL isSuccessSaveAppStateInBackGround;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 进入前台时 需要撤销进入后台时 申请的 额外时间任务
    [self emptyEnterBackGroundTimerAndTask];
    
    if(self.isSuccessSaveAppStateInBackGround == YES){ // app 进入后台时间过长, 且挂起之前已经对状态进行保存, 现在app 进入前台, 需要恢复
        self.isSuccessSaveAppStateInBackGround = NO;
        // 恢复app 至 进入前台时刻 状态
        // do anything ...
    }
    
}



//使用此方法释放共享资源、保存用户数据、使计时器失效，并存储足够的应用程序状态信息，以便在稍后终止应用程序时将其恢复到当前态。
//如果应用程序支持后台执行，则调用此方法而不是应用程序将在用户退出时终止。
- (void)applicationDidEnterBackground:(UIApplication *)application { // 如果来到此方法没有申请额外的任务时间, app 程序直接挂起
    
//    // 测试最长后台时间
//    [self testEnterBackgroundMaxTimeLen];
//    return;
    
    // 重置状态标记
    self.isSuccessSaveAppStateInBackGround = NO;
    
    // 申请 额外时间任务
    [self update_requestAdditionalExecutionTimeTask];

    // 更新后台倒计时器
    __weak typeof(self) weakSelf = self;
    [self updateEnterBackGroundTimer_timeroutCallBack:^{
        
        //  你需要在这里, 保存你的手机状态, 以便在app 进入前台后恢复
        // do anything...
        weakSelf.isSuccessSaveAppStateInBackGround = YES;
    }];
}


/**
  申请 额外时间任务(3分钟)
 */
-(void)update_requestAdditionalExecutionTimeTask{
    
    __weak typeof(self) weakSelf = self;
    // 申请 额外的后台时间
    self.bgTaskId = [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^{// 后台任务超时未完成会回调来这里
       [weakSelf emptyEnterBackGroundTimerAndTask];
        
    }];
}

/**
 更新 后台倒计时器
 */
-(void)updateEnterBackGroundTimer_timeroutCallBack:(void(^)(void))timeroutCallBack{
    
    __weak typeof(self) weakSelf = self;
    self.enterBackGroundTimer = [NSTimer scheduledTimerWithTimeInterval:EnterBGround_MaxTimeInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        [weakSelf emptyEnterBackGroundTimerAndTask];
        if(timeroutCallBack){
            timeroutCallBack();
        }
    }];
}

/**
 清空后台倒计时器 和 额外时间任务
 */
-(void)emptyEnterBackGroundTimerAndTask{
    [self emptyEnterBackGroundTimer];
    [self emptyBackgroundTask];
}

/**
 清空后台倒计时器
 */
-(void)emptyEnterBackGroundTimer{
    if (self.enterBackGroundTimer) {
        [self.enterBackGroundTimer invalidate];
        self.enterBackGroundTimer = nil;
    }
}

/** 清空额外时间任务
 */
-(void)emptyBackgroundTask{
    if (self.bgTaskId != UIBackgroundTaskInvalid ) {
        // 申请了额外的后台时间, 就必须要有对应的关闭 扯回销
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
        self.bgTaskId = UIBackgroundTaskInvalid;
    }
}


// 测试当前应用程序进入后台, 最长支撑时间(程序被挂起前)
-(void)testEnterBackgroundMaxTimeLen{
    NSLog(@"=========应用程序开始进入后台========");
    [[RGLogTool shareTool] startRecord];
    
    // 申请后台处理  额外时间
    __block  UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^{ // 当应用程序 申请的后台时间用完就会回调这个block 通知你, 一般现在是3 分钟
        
        if (bgTaskId != UIBackgroundTaskInvalid ) {
            [[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
            bgTaskId = UIBackgroundTaskInvalid;
        }
        
        [[RGLogTool shareTool] stopRecord];
        NSLog(@"=========应用程序 常时间进入后台== 系统程序已被挂起======");
        
    }];
}




@end
