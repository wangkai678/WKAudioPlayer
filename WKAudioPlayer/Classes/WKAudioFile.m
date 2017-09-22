//
//  WKAudioFile.m
//  Pods
//
//  Created by 王凯 on 17/9/19.
//
//

#import "WKAudioFile.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

#define kTempPath NSTemporaryDirectory()

@implementation WKAudioFile

+ (NSString *)cacheFilePath:(NSURL *)url {
    return [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (long long)cacheFileSize:(NSURL *)url {
    if (![self cacheFileExists:url]) {
        return 0;
    }
    NSString *path = [self cacheFilePath:url];
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileInfoDic[NSFileSize] longLongValue] ;
}

+ (BOOL)cacheFileExists:(NSURL *)url {
    NSString *path = [self cacheFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}



+ (NSString *)tempFilePath:(NSURL *)url {
   return [kTempPath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (long long)tempFileSize:(NSURL *)url {
    if (![self tempFileExists:url]) {
        return 0;
    }
    NSString *path = [self tempFilePath:url];
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [fileInfoDic[NSFileSize] longLongValue] ;
}

+ (BOOL)tempFileExists:(NSURL *)url {
    NSString *path = [self tempFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (void)clearTempFile:(NSURL *)url {
    NSString *tempPath = [self tempFilePath:url];
    BOOL isDirectory = YES;
    BOOL isEx = [[NSFileManager defaultManager] fileExistsAtPath:tempPath isDirectory:&isDirectory];
    if (isEx && !isDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    }
}


+ (NSString *)contentType:(NSURL *)url {
    NSString *path = [self cacheFilePath:url];
    NSString *fileExtension = path.pathExtension;
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}

+ (void)moveTempPathToCachePath:(NSURL *)url {
    NSString *tempPath = [self tempFilePath:url];
    NSString *cachePath = [self cacheFilePath:url];
    [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:cachePath error:nil];
}

@end
