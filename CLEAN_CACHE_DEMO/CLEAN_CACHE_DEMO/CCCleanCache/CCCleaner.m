//
//  CCCleaner.m
//  CLEAN_CACHE_DEMO
//
//  Created by 冯明庆 on 16/11/16.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "CCCleaner.h"

#if COCOAPODS
#import <SDWebImage/SDImageCache.h>
#else
#import "SDImageCache.h"
#endif

/// 1 开启日志输出 , 0 关闭日志输出 .
#if 1
    #if DEBUG
        #define CC_CLEANER_LOG(fmt , ...) NSLog((@"\n\n_CC_CLEANER_LOG_\n\n_CC_FILE_  %s\n_CC_METHOND_  %s\n_CC_LINE_  %d\n" fmt),__FILE__,__func__,__LINE__,##__VA_ARGS__)
    #else
        #define CC_CLEANER_LOG(fmt , ...) /* */
    #endif
#else
    #define CC_CLEANER_LOG(fmt , ...) /* */
#endif

@interface CCCleaner ()

@property (nonatomic , strong) NSFileManager * fileManager ;

- (void) ccDefaultSettings ;

- (long long) ccGetFileSizeWithPath : (NSString *) filePath ;

- (double) ccGetWebCacheWithIsNeedClean : (BOOL) isNeed ;

- (double) ccGetImageCacheWithIsNeedClean : (BOOL) isNeed ;

- (BOOL) ccDeleteAllFilesInFolder : (NSString *) stringFolderPath ;

@end

@implementation CCCleaner

+ (instancetype) sharedCCCleaner {
    static CCCleaner *_cleaner;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cleaner = [[CCCleaner alloc] init];
    });
    return _cleaner;
}

- (void) ccCleanCacheWithPath : (NSArray *) arrayPath
        withCompletionHandler : (CCCompletionHandler) handler {
    CCCompletionStatus status = CCCompletionStatusFailed;
    if (!arrayPath || !arrayPath.count) {
        arrayPath = [NSArray arrayWithArray:_arrayDefaultCacheFolder];
        status = CCCompletionStatusDefaultFolder ;
    } else {
        status = CCCompletionStatusSucceed ;
    }
    
    if (!arrayPath || !arrayPath.count) {
        status = CCCompletionStatusUnknow;
        NSError *error = [NSError errorWithDomain:@"_CC_FOLDER_EMPTY_CLEANED_WEB_&&_IMAGE_CACHE"
                                             code:-10102
                                         userInfo:nil];
        [self ccGetWebCacheWithIsNeedClean:YES];
        [self ccGetImageCacheWithIsNeedClean:YES];
        if (handler) {
            handler(status , error);
        }
        CC_CLEANER_LOG(@"%@",error);
        return ;
    }
    
    NSMutableArray *arrayFolderAlreadyCleaned = [NSMutableArray array];
    for (NSString *stringFolderPath in arrayPath) {
        if ([self ccDeleteAllFilesInFolder:stringFolderPath]) {
            if (stringFolderPath) {
                [arrayFolderAlreadyCleaned addObject:stringFolderPath];
            }
        };
    }
    [self ccGetWebCacheWithIsNeedClean:YES];
    [self ccGetImageCacheWithIsNeedClean:YES];
    if (handler) {
        handler(status , arrayFolderAlreadyCleaned);
    }
}

- (double) ccGetCacheSizeWithFolderPath : (NSArray *) arrayPath
                  withCompletionHandler : (CCCompletionHandler) handler {
    CCCompletionStatus status = CCCompletionStatusFailed;
    if (!arrayPath || !arrayPath.count) {
        arrayPath = [NSArray arrayWithArray:_arrayDefaultCacheFolder];
        status = CCCompletionStatusDefaultFolder ;
    } else {
        status = CCCompletionStatusSucceed ;
    }
    
    if (!arrayPath || !arrayPath.count) {
        status = CCCompletionStatusError;
        NSError *error = [NSError errorWithDomain:@"_CC_FOLDER_EMPTY_" code:-10101 userInfo:nil];
        if (handler) {
            handler(status , error);
        }
        CC_CLEANER_LOG(@"%@",error);
        return 0;
    }
    
    double folderSize = 0;
    for (NSString *tempFolderPath in arrayPath) {
        if (![_fileManager fileExistsAtPath:tempFolderPath]) return 0;
        NSEnumerator *filesEnumerator = [[_fileManager subpathsAtPath:tempFolderPath] objectEnumerator];
        NSString *fileName;
        while ((fileName = [filesEnumerator nextObject]) != nil) {
            NSString *filePath = [tempFolderPath stringByAppendingPathComponent:fileName];
            folderSize += [self ccGetFileSizeWithPath:filePath];
        }
    }
    folderSize += [self ccGetWebCacheWithIsNeedClean:NO];
    folderSize += [self ccGetImageCacheWithIsNeedClean:NO];
    if (handler) {
        handler(status , @(folderSize));
    }
    return (folderSize / 1024.0f / 1024.0f);
}

- (NSString *) ccStringGetCacheSizeWithFolderPath : (NSArray *) arrayPath
                                     withSizeUnit : (BOOL) isNeed
                            withCompletionHandler : (CCCompletionHandler) handler {
    double folderSize = [self ccGetCacheSizeWithFolderPath:arrayPath
                                     withCompletionHandler:nil];
    NSString *stringCacheSize = [NSString stringWithFormat:@"%lf",folderSize];
    NSArray *array = [stringCacheSize componentsSeparatedByString:@"."];
    NSString *stringSize = [NSString stringWithFormat:@"%@.%@%@" , [array firstObject] ,
                            [[array lastObject] substringToIndex:2] ,
                            isNeed ? @" M" : @""];
    if (handler) {
        if (folderSize <= 0) {
            handler(CCCompletionStatusUnknow , nil);
            return [NSString stringWithFormat:@"0.0%@",isNeed ? @" M" : @""];
        }
        handler(CCCompletionStatusSucceed , stringSize);
    }
    return stringSize;
}

- (void) ccStartCleanCacheWithCompletionHandler : (CCCompletionHandler) handler{
    [self ccCleanCacheWithPath:_arrayDefaultCacheFolder
         withCompletionHandler:handler];
}

#pragma mark - Private method (s)

- (instancetype)init {
    if ((self = [super init])) {
        [self ccDefaultSettings];
    }
    return self;
}

/// 默认缓存文件夹 . 
- (void) ccDefaultSettings {
    [self arrayDefaultCacheFolder];
    _fileManager = [NSFileManager defaultManager];
}

- (long long) ccGetFileSizeWithPath : (NSString *) filePath {
    if ([_fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil ;
        NSDictionary *dictionaryFileInfo = [_fileManager attributesOfItemAtPath:filePath error:&error];
        if (error) {
            CC_CLEANER_LOG(@"%@",error);
            return 0;
        }
        return [dictionaryFileInfo fileSize];
    }
    return 0;
}

- (double) ccGetWebCacheWithIsNeedClean : (BOOL) isNeed {
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    if (isNeed) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
            [cookieStorage deleteCookie:cookie];
        }
        [urlCache removeAllCachedResponses];
        return 0.0f;
    } else {
        return urlCache.currentMemoryUsage + urlCache.currentDiskUsage;
    }
}

- (double) ccGetImageCacheWithIsNeedClean : (BOOL) isNeed {
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    if (isNeed) {
        [imageCache clearMemory];
        [imageCache clearDiskOnCompletion:^{
            
        }];
        return 0 ;
    } else {
        return [imageCache getSize];
    }
}

- (BOOL) ccDeleteAllFilesInFolder : (NSString *) stringFolderPath {
    NSError *error;
    NSArray * arrayAllFileName = [_fileManager contentsOfDirectoryAtPath:stringFolderPath error:&error];
    if (error) {
        CC_CLEANER_LOG(@"%@",error);
        return NO;
    }
    for (NSString * fileName in arrayAllFileName) {
        BOOL isDirectory = YES;
        NSString * stringFullFilePath = [stringFolderPath stringByAppendingPathComponent:fileName];
        if ([_fileManager fileExistsAtPath:stringFullFilePath isDirectory:&isDirectory]) {
            if (!isDirectory) {
                NSError *error = nil;
                if (![_fileManager removeItemAtPath:stringFullFilePath error:&error]) {
                    if (error) {
                        CC_CLEANER_LOG(@"%@",error);
                    }
                }
            }
        }
    }
    return YES;
}

#pragma mark - Getter
- (NSArray<NSString *> *)arrayDefaultCacheFolder {
    if (_arrayDefaultCacheFolder) return _arrayDefaultCacheFolder;
    _arrayDefaultCacheFolder = @[];
    return _arrayDefaultCacheFolder;
}

- (void) dealloc {
    CC_CLEANER_LOG(@"_CC_CLEANER_DEALLOC_");
}

@end
