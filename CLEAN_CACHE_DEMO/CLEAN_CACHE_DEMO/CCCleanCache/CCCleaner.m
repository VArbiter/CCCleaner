//
//  CCCleaner.m
//  CLEAN_CACHE_DEMO
//
//  Created by 冯明庆 on 16/11/16.
//  Copyright © 2016年 冯明庆. All rights reserved.
//

#import "CCCleaner.h"

@import WebKit;

#if COCOAPODS
    @import SDWebImage;
#else
    #import "SDImageCache.h"
#endif

static BOOL __isEnableCleanerLog = false;

/// 1 开启日志输出 , 0 关闭日志输出 .
#if __isEnableCleanerLog
    #if DEBUG
        #define CC_CLEANER_LOG(fmt , ...) NSLog((@"\n\n_CC_CLEANER_LOG_\n\n_CC_FILE_  %s\n_CC_METHOND_  %s\n_CC_LINE_  %d\n" fmt),__FILE__,__func__,__LINE__,##__VA_ARGS__)
    #else
        #define CC_CLEANER_LOG(fmt , ...) /* */
    #endif
#else
    #define CC_CLEANER_LOG(fmt , ...) /* */
#endif

@interface CCCleaner () <NSCopying , NSMutableCopying>

@property (nonatomic , strong) NSFileManager * fileManager ;

- (void) ccDefaultSettings ;

- (long long) ccGetFileSizeWithPath : (NSString *) filePath ;

- (long double) ccGetWebCacheWithIsNeedClean : (BOOL) isNeed ;

- (long double) ccGetImageCacheWithIsNeedClean : (BOOL) isNeed ;

- (long double) ccGetWkWebCacheWithIsNeedClean : (BOOL) isNeed ;

- (BOOL) ccDeleteAllFilesInFolder : (NSString *) sFolderPath ;

@end

static CCCleaner *__instance = nil;

@implementation CCCleaner

+ (instancetype) shared{
    if (__instance) return __instance;
    __instance = [[self alloc] init];
    return __instance;
}

- (instancetype)ccEnableLog {
    __isEnableCleanerLog = YES;
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (__instance) return __instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [super allocWithZone:zone];
    });
    return __instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return __instance;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    return __instance;
}

- (void) ccClean : (NSString *) sPathFull
      completion : (CCCompletionHandler) handler {
    CCCompletionStatus status = CCCompletionStatusFailed;
    if (!sPathFull || !sPathFull.length) {
        status = CCCompletionStatusError;
        NSError *error = [NSError errorWithDomain:@"_CC_FILE_PATH_EMPTY_"
                                             code:-10103
                                         userInfo:nil];
        if (handler) {
            handler(status , error);
        }
        return;
    }
    BOOL isDirectory = NO;
    if ([_fileManager fileExistsAtPath:sPathFull isDirectory:&isDirectory]) {
        NSError *error = nil;
        if (!isDirectory) {
            if (![_fileManager removeItemAtPath:sPathFull error:&error]) {
                if (error) CC_CLEANER_LOG(@"%@",error);
                if (handler) handler(status , error);
            } else {
                status = CCCompletionStatusSucceed;
                if (handler) handler(status , nil);
            }
        } else {
            error = [NSError errorWithDomain:@"_CC_FILE_PATH_IS_FOLDER_"
                                        code:-10104
                                    userInfo:nil];
            if (handler) handler(status , error);
        }
    }
}

- (void) ccCleanMuti : (NSArray *) aPath
          completion : (CCCompletionHandler) handler {
    CCCompletionStatus status = CCCompletionStatusFailed;
    if (!aPath || !aPath.count) {
        aPath = [NSArray arrayWithArray:_arrayDefaultCacheFolder];
        status = CCCompletionStatusDefaultFolder ;
    }
    else status = CCCompletionStatusSucceed ;
    
    if (!aPath || !aPath.count) {
        status = CCCompletionStatusUnknow;
        NSError *error = [NSError errorWithDomain:@"_CC_FOLDER_EMPTY_CLEANED_WEB_&&_IMAGE_CACHE"
                                             code:-10102
                                         userInfo:nil];
        [self ccGetWebCacheWithIsNeedClean:YES];
        [self ccGetWkWebCacheWithIsNeedClean:YES];
        [self ccGetImageCacheWithIsNeedClean:YES];
        if (handler) handler(status , error);
        CC_CLEANER_LOG(@"%@",error);
        return ;
    }
    
    NSMutableArray *aFolderAlreadyCleaned = [NSMutableArray array];
    for (NSString *sPathT in aPath) {
        if ([self ccDeleteAllFilesInFolder:sPathT]) {
            if (sPathT) [aFolderAlreadyCleaned addObject:sPathT];
        };
    }
    [self ccGetWebCacheWithIsNeedClean:YES];
    [self ccGetWkWebCacheWithIsNeedClean:YES];
    [self ccGetImageCacheWithIsNeedClean:YES];
    if (handler) handler(status , aFolderAlreadyCleaned);
}

- (long double) ccMutiCacheSize : (NSArray *) aPath
                     completion : (CCCompletionHandler) handler {
    CCCompletionStatus status = CCCompletionStatusFailed;
    if (!aPath || !aPath.count) {
        aPath = [NSArray arrayWithArray:_arrayDefaultCacheFolder];
        status = CCCompletionStatusDefaultFolder ;
    }
    else status = CCCompletionStatusSucceed ;
    
    if (!aPath || !aPath.count) {
        status = CCCompletionStatusError;
        NSError *error = [NSError errorWithDomain:@"_CC_FOLDER_EMPTY_" code:-10101 userInfo:nil];
        if (handler) handler(status , error);
        CC_CLEANER_LOG(@"%@",error);
        return 0;
    }
    
    long double folderSize = 0;
    for (NSString *tempFolderPath in aPath) {
        if (![_fileManager fileExistsAtPath:tempFolderPath]) return 0;
        NSEnumerator *filesEnumerator = [[_fileManager subpathsAtPath:tempFolderPath] objectEnumerator];
        NSString *fileName;
        while ((fileName = [filesEnumerator nextObject]) != nil) {
            NSString *filePath = [tempFolderPath stringByAppendingPathComponent:fileName];
            folderSize += [self ccGetFileSizeWithPath:filePath];
        }
    }
    folderSize += [self ccGetWebCacheWithIsNeedClean:NO];
    folderSize += [self ccGetWkWebCacheWithIsNeedClean:NO];
    folderSize += [self ccGetImageCacheWithIsNeedClean:NO];
    if (handler) handler(status , @((NSUInteger)folderSize));
    return (folderSize / 1024.0f / 1024.0f);
}

- (NSString *) ccMutiCacheSize : (NSArray *) aPath
                      sizeUnit : (BOOL) isNeed
                    completion : (CCCompletionHandler) handler {
    long double folderSize = [self ccMutiCacheSize:aPath
                                        completion:nil];
    NSString *sCacheSize = [NSString stringWithFormat:@"%Lf",folderSize];
    NSArray *array = [sCacheSize componentsSeparatedByString:@"."];
    NSString *sSize = [NSString stringWithFormat:@"%@.%@%@" , [array firstObject] ,
                            [[array lastObject] substringToIndex:2] ,
                            isNeed ? @" M" : @""];
    if (handler) {
        if (folderSize <= 0) {
            handler(CCCompletionStatusUnknow , nil);
            return [NSString stringWithFormat:@"0.0%@",isNeed ? @" M" : @""];
        }
        handler(CCCompletionStatusSucceed , sSize);
    }
    return sSize;
}

- (void) ccStartCleanCacheByDefault : (CCCompletionHandler) handler {
    [self ccCleanMuti:self.arrayDefaultCacheFolder
           completion:handler];
}

- (void) ccCleanWebCache : (CCCompletionHandler) handler {
    long double dTotal = .0f;
    dTotal += [self ccGetWebCacheWithIsNeedClean:YES];
    dTotal += [self ccGetWkWebCacheWithIsNeedClean:YES];
    if (handler) handler(CCCompletionStatusSucceed ,  @((NSUInteger)dTotal));
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

- (long double) ccGetWebCacheWithIsNeedClean : (BOOL) isNeed {
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

- (long double) ccGetWkWebCacheWithIsNeedClean : (BOOL) isNeed {
    NSString *stringLibraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                       NSUserDomainMask,
                                                                       YES) firstObject];
    NSString *stringBundleId  =  [[[NSBundle mainBundle] infoDictionary]
                                  objectForKey:@"CFBundleIdentifier"];
    NSString *stringFolderInLib = [NSString stringWithFormat:@"%@/WebKit",stringLibraryPath];
    NSString *stringFolderInCaches = [NSString
                                      stringWithFormat:@"%@/Caches/%@/WebKit",stringLibraryPath,stringBundleId];
    
    long double doublefolderSize = .0f;
    NSEnumerator *filesEnumerator = [[_fileManager subpathsAtPath:stringFolderInLib] objectEnumerator];
    NSString *fileName;
    while ((fileName = [filesEnumerator nextObject]) != nil) {
        NSString *filePath = [stringFolderInLib stringByAppendingPathComponent:fileName];
        doublefolderSize += [self ccGetFileSizeWithPath:filePath];
    }
    
    filesEnumerator = [[_fileManager subpathsAtPath:stringFolderInCaches] objectEnumerator];
    while ((fileName = [filesEnumerator nextObject]) != nil) {
        NSString *filePath = [stringFolderInCaches stringByAppendingPathComponent:fileName];
        doublefolderSize += [self ccGetFileSizeWithPath:filePath];
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if (isNeed) {
        /*
        //选择删除一些文件
        NSSet *setDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,
                                                    WKWebsiteDataTypeOfflineWebApplicationCache,
                                                    WKWebsiteDataTypeMemoryCache,
                                                    WKWebsiteDataTypeLocalStorage,
                                                    WKWebsiteDataTypeCookies,
                                                    WKWebsiteDataTypeSessionStorage,
                                                    WKWebsiteDataTypeIndexedDBDatabases,
                                                    WKWebsiteDataTypeWebSQLDatabases]];
         */
        // 删除所有缓存
        NSSet *setDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:setDataTypes
                                                   modifiedSince:dateFrom
                                               completionHandler:^{/*Code*/}];
    }
#else
    NSString *stringFolderInCachesfs = [NSString
                                        stringWithFormat:@"%@/Caches/%@/fsCachedData",stringLibraryPath,stringBundleId];
    filesEnumerator = [[_fileManager subpathsAtPath:stringFolderInCachesfs] objectEnumerator];
    while ((fileName = [filesEnumerator nextObject]) != nil) {
        NSString *filePath = [stringFolderInCachesfs stringByAppendingPathComponent:fileName];
        doublefolderSize += [self ccGetFileSizeWithPath:filePath];
    }
    
    if (isNeed) {
        [self ccDeleteAllFilesInFolder:stringFolderInCachesfs];
    }
#endif
    return doublefolderSize;
}

- (long double) ccGetImageCacheWithIsNeedClean : (BOOL) isNeed {
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

- (BOOL) ccDeleteAllFilesInFolder : (NSString *) sFolderPath {
    NSError *error;
    NSArray * arrayAllFileName = [_fileManager contentsOfDirectoryAtPath:sFolderPath error:&error];
    if (error) {
        CC_CLEANER_LOG(@"%@",error);
        return NO;
    }
    for (NSString * fileName in arrayAllFileName) {
        BOOL isDirectory = YES;
        NSString * stringFullFilePath = [sFolderPath stringByAppendingPathComponent:fileName];
        if ([_fileManager fileExistsAtPath:stringFullFilePath isDirectory:&isDirectory]) {
            if (!isDirectory) {
                NSError *error = nil;
                if (![_fileManager removeItemAtPath:stringFullFilePath error:&error]) {
                    if (error) CC_CLEANER_LOG(@"%@",error);
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
