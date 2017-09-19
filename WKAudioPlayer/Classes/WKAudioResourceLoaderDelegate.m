//
//  WKAudioResourceLoaderDelegate.m
//  Pods
//
//  Created by 王凯 on 17/9/18.
//
//

#import "WKAudioResourceLoaderDelegate.h"
#import "WKAudioFile.h"

@implementation WKAudioResourceLoaderDelegate

//当外界需要播放一段音频资源时会抛一个请求给这个对象，这个对象只需要根据请求信息抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"%@",loadingRequest);
    //判断本地有没有该音频资源的缓存文件，如果有则直接根据本地缓存向外界响应数据
    NSURL *url = loadingRequest.request.URL;
    if ([WKAudioFile cacheFileExists:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    //如果当前正在下载
    
    
    
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"取消请求");
}

#pragma mark - 私有方法
//处理本地已经下载好的资源
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //填充响应的信息头信息
    
    NSURL *url = loadingRequest.request.URL;
    long long totalSize = [WKAudioFile cacheFileSize:url];
    NSString *contentType = [WKAudioFile contentType:url];
    loadingRequest.contentInformationRequest.contentLength = totalSize;
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    //响应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:[WKAudioFile cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    [loadingRequest.dataRequest respondWithData:subData];
    //完成本次请求（一旦所有的数据都给完了，才能调用完成请求方法）
    [loadingRequest finishLoading];
}

@end
