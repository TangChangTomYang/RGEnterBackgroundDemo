//
//  RGLogTool.h
//  RGEnterBackgroundDemo
//
//  Created by yangrui on 2019/2/26.
//  Copyright © 2019年 yangrui. All rights reserved.
//  此工具只是用于测试, App 从进入后台 到程序挂起的时长

#import <Foundation/Foundation.h>

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
@interface RGLogTool : NSObject

/**文件输出流*/
@property(nonatomic, strong)NSOutputStream *outputStream;
@property(nonatomic, strong)NSTimer *logTimer;


+(instancetype)shareTool;
-(void)startRecord;
-(void)stopRecord;
@end



