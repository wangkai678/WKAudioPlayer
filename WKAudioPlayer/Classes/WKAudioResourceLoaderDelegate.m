//
//  WKAudioResourceLoaderDelegate.m
//  Pods
//
//  Created by 王凯 on 17/9/18.
//
//

#import "WKAudioResourceLoaderDelegate.h"

@implementation WKAudioResourceLoaderDelegate

//当外界需要播放一段音频资源时会抛一个请求给这个对象，这个对象只需要根据请求信息抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"%@",loadingRequest);
    //填充响应的信息头信息
    loadingRequest.contentInformationRequest.contentLength = 4093201;
    loadingRequest.contentInformationRequest.contentType = @"public.mp3";
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    //响应数据给外界
    NSData *data = [NSData dataWithContentsOfFile:@"" options:NSDataReadingMappedIfSafe error:nil];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    [loadingRequest.dataRequest respondWithData:subData];
    //完成本次请求（一旦所有的数据都给完了，才能调用完成请求方法）
    [loadingRequest finishLoading];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"取消请求");
}

@end
