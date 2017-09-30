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

// eg :
// CCCleaner * cleaner = CCCleaner.shared ; // 默认关闭日志
// CCCleaner * cleaner = CCCleaner.shared.ccEnableLog ; // 开启日志

+ (instancetype) shared ;
- (instancetype) ccEnableLog; // 默认关闭 LOG , 需要调用这个方法来开启 (主要是错误输出)

/// 默认文件夹路径
@property (nonatomic , strong) NSArray <NSString *> * arrayDefaultCacheFolder ;

/// 删除指定文件
- (void) ccClean : (NSString *) sPathFull
      completion : (CCCompletionHandler) handler;

/// 清除指定路径组下的缓存 , nil 默认
- (void) ccCleanMuti : (NSArray *) aPath
          completion : (CCCompletionHandler) handler;

/// 获得指定路径组下文件总大小 , nil 默认
- (long double) ccMutiCacheSize : (NSArray *) aPath
                     completion : (CCCompletionHandler) handler;

/// 用来显示指定路径组缓存占用多少空间 eg: @return 2.57 / 2.57M , nil 默认
- (NSString *) ccMutiCacheSize : (NSArray *) aPath
                      sizeUnit : (BOOL) isNeed
                    completion : (CCCompletionHandler) handler;

/// 清除默认缓存文件夹的缓存 .
- (void) ccStartCleanCacheByDefault : (CCCompletionHandler) handler;

/// 删除 UiWebView 和 WKWebView 的缓存
- (void) ccCleanWebCache : (CCCompletionHandler) handler ;

@end
