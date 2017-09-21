//
//  WKAudioFile.h
//  Pods
//
//  Created by 王凯 on 17/9/19.
//
//

#import <Foundation/Foundation.h>

@interface WKAudioFile : NSObject


/**
 根据url获取相应的本地缓存路径，下载完成的路径，即cache＋文件名称
 */
+ (NSString *)cacheFilePath:(NSURL *)url;
//计算缓存文件大小
+ (long long)cacheFileSize:(NSURL *)url;
+ (BOOL)cacheFileExists:(NSURL *)url;



+ (NSString *)tempFilePath:(NSURL *)url;
//计算临时文件大小
+ (long long)tempFileSize:(NSURL *)url;
+ (BOOL)tempFileExists:(NSURL *)url;
+ (void)clearTempFile:(NSURL *)url;


+ (NSString *)contentType:(NSURL *)url;

+ (void)moveTempPathToCachePath:(NSURL *)url;

@end
