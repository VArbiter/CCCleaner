//
//  CCCleaner.h
//  CLEAN_CACHE_DEMO
//
//  Created by 冯明庆 on 16/11/16.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , CCCompletionStatus) {
    CCCompletionStatusFailed = 0 ,
    CCCompletionStatusSucceed ,
    CCCompletionStatusError ,
    CCCompletionStatusUnknow ,
    CCCompletionStatusDefaultFolder
};

typedef void(^CCCompletionHandler)(CCCompletionStatus status , id item);

@interface CCCleaner : NSObject

+ (instancetype) sharedCCCleaner ;

/// 默认文件夹路径
@property (nonatomic , strong) NSArray <NSString *> * arrayDefaultCacheFolder ;

/// 清除指定路径组下的缓存 , nil 默认
- (void) ccCleanCacheWithPath : (NSArray *) arrayPath
        withCompletionHandler : (CCCompletionHandler) handler;

/// 获得指定路径组下文件总大小 , nil 默认
- (double) ccGetCacheSizeWithFolderPath : (NSArray *) arrayPath
                  withCompletionHandler : (CCCompletionHandler) handler;

/// 用来显示指定路径组缓存占用多少空间 eg: @return 2.57 / 2.57M , nil 默认
- (NSString *) ccStringGetCacheSizeWithFolderPath : (NSArray *) arrayPath
                                     withSizeUnit : (BOOL) isNeed
                            withCompletionHandler : (CCCompletionHandler) handler;

/// 清除默认缓存文件夹的缓存 .
- (void) ccStartCleanCacheWithCompletionHandler : (CCCompletionHandler) handler;

@end
