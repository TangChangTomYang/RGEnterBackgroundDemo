//
//  RGLogTool.m
//  RGEnterBackgroundDemo
//
//  Created by yangrui on 2019/2/26.
//  Copyright © 2019年 yangrui. All rights reserved.
//

#import "RGLogTool.h"

@implementation RGLogTool


static RGLogTool *_testTool = nil;

+(instancetype)shareTool{
    if (_testTool == nil) {
        _testTool = [[self alloc] init];
    }
    return _testTool;
}

-(NSString *)logFielPath{
    NSString *path = [kCachePath  stringByAppendingPathComponent:@"log.txt"];
    return path;
}



static long  count = 0;
-(void)startRecord{
    if (self.logTimer) {
        [self.logTimer invalidate];
        self.logTimer = nil;
    }
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[self logFielPath]  append:YES];
    [self.outputStream open];
    count = 0;
    self.logTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordCount) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.logTimer forMode:NSRunLoopCommonModes];
    
    [self writeInfo:@"startRecord log-----\n"];
}

-(void)recordCount{
    count += 1;
    NSString *countStr = [NSString stringWithFormat:@"%ld\n",count];
    [self writeInfo:countStr];
}

-(void)writeInfo:(NSString *)info{
    
    NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
    // 将数据写入文件
    [self.outputStream write:data.bytes maxLength:data.length];
}

-(void)stopRecord{
    [self writeInfo:@"stopRecord log-----\n"];
    [self.outputStream close];
    [self.logTimer invalidate];
    self.logTimer = nil;
}





@end
