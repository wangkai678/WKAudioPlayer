//
//  WKAudioResourceLoaderDelegate.m
//  Pods
//
//  Created by 王凯 on 17/9/18.
//
//

#import "WKAudioResourceLoaderDelegate.h"
#import "WKAudioFile.h"
#import "WKAudioDownLoader.h"
#import "NSURL+WK.h"

@interface WKAudioResourceLoaderDelegate ()<WKAudioDownLoaderDelegate>

@property (nonatomic, strong)WKAudioDownLoader *doenLoader;
@property (nonatomic ,strong)NSMutableArray *loadingRequests;

@end

@implementation WKAudioResourceLoaderDelegate

- (WKAudioDownLoader *)doenLoader {
    if (!_doenLoader) {
        _doenLoader = [[WKAudioDownLoader alloc] init];
        _doenLoader.delegate = self;
    }
    return _doenLoader;
}

- (NSMutableArray *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}

//当外界需要播放一段音频资源时会抛一个请求给这个对象，这个对象只需要根据请求信息抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSURL *url = [loadingRequest.request.URL httpURL];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    //判断本地有没有该音频资源的缓存文件，如果有则直接根据本地缓存向外界响应数据
    if ([WKAudioFile cacheFileExists:url]) {
        [self handleLoadingRequest:loadingRequest];
        return YES;
    }
    
    //记录所有的请求
    [self.loadingRequests addObject:loadingRequest];
    
    //如果当前没有下载则开始下载
    if(self.doenLoader.loadedSize ==0){
        [self.doenLoader downLoadwithURL:url offset:requestOffset];
        return YES;
    }
    
    　//判断是否需要重新下载
    //1.当资源请求的开始点小于下载的开始点
    //2.当资源的请求开始点>（下载的开始点＋下载的长度 + 666）
    if (requestOffset < self.doenLoader.offset || requestOffset > (self.doenLoader.offset + self.doenLoader.loadedSize + 666)) {
        [self.doenLoader downLoadwithURL:url offset:requestOffset];
        return YES;
    }
    
    //开始处理资源请求(在下载过程当中也要判断)
    [self handleAllLoadingRequest];
    
    return YES;
    
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"取消请求");
    [self.loadingRequests removeObject:loadingRequest];
}

#pragma mark - WKAudioDownLoaderDelegate
- (void)downLoading {
    [self handleAllLoadingRequest];
}

- (void)handleAllLoadingRequest {
    NSMutableArray *deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        //1.填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.doenLoader.totalSize;//获取总大小
        NSString *contentType = self.doenLoader.mimeType;//获取文件类型
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        //2.填充数据
        NSData *data = [NSData dataWithContentsOfFile:[WKAudioFile tempFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        long long responseOffset = requestOffset - self.doenLoader.offset;
        long long responseLength = MIN(self.doenLoader.offset + self.doenLoader.loadedSize - requestOffset, requestLength);
        
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        [loadingRequest.dataRequest respondWithData:subData];
        
        //完成请求(必须把所有的关于这个请求的区间数据都返回之后才能完成这个请求)
        if(requestLength == responseLength){
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
    }
    [self.loadingRequests removeObjectsInArray:deleteRequests];
}

#pragma mark - 私有方法
//处理本地已经下载好的资源
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //填充响应的信息头信息
    
    NSURL *url = loadingRequest.request.URL;
    long long totalSize = [WKAudioFile cacheFileSize:url];//获取总大小
    NSString *contentType = [WKAudioFile contentType:url];//获取文件类型
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
