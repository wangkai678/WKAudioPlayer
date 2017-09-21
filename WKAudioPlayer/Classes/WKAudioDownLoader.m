//
//  WKAudioDownLoader.m
//  Pods
//
//  Created by wangkai on 2017/9/21.
//
//

#import "WKAudioDownLoader.h"
#import "WKAudioFile.h"

@interface WKAudioDownLoader ()<NSURLSessionDataDelegate>

@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic ,strong) NSOutputStream *outputStream;
@property (nonatomic ,assign) long long totalSize;
@property (nonatomic ,strong) NSURL *url;


@end

@implementation WKAudioDownLoader

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)downLoadwithURL:(NSURL *)url offset:(long long)offset {
    [self cancelAndClean];
    self.url = url;
    //请求某一个区间的数据range
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
}

- (void)cancelAndClean {
    [self.session invalidateAndCancel];
    self.session = nil;
    //清空本地已经存储的临时缓存
    [WKAudioFile clearTempFile:self.url];
    self.loadedSize = 0;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    //从Content-Length取出来，如果Content-Range有值则应该从Content-Range里面获取
    self.totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        self.totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[WKAudioFile tempFilePath:self.url] append:YES];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    self.loadedSize += data.length;
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        //临时文件夹可能下载的是音频片段，当只有下载完整的音频的时候才移动
        NSURL *url = self.url;
        if ([WKAudioFile tempFileSize:task.response.URL] == self.totalSize) {
            //从临时文件夹移动到cache文件夹
            [WKAudioFile moveTempPathToCachePath:url];
        }
    }else{
        NSLog(@"有错误");
    }
}


@end
