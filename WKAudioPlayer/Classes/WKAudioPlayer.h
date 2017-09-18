//
//  WKAudioPlayer.h
//  Pods
//
//  Created by 王凯 on 17/9/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WKAudioPlayerState) {
    WKAudioPlayerStateUnknown = 0,
    WKAudioPlayerStateLoading = 1,
    WKAudioPlayerStatePlaying = 2,
    WKAudioPlayerStateStopped = 3,
    WKAudioPlayerStatePause   = 4,
    WKAudioPlayerStateFailed  = 5
};

@interface WKAudioPlayer : NSObject

+ (instancetype)shareInstance;

//播放
- (void)playerWithURL:(NSURL *)url;

//暂停
- (void)pause;

//恢复
- (void)resume;

//停止
- (void)stop;

//快进或快退
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;

//设置进度
- (void)seekWithTimeProgress:(float)progress;

@property (nonatomic, assign) BOOL muted;//静音
@property (nonatomic, assign) float volume;//音量
@property (nonatomic, assign) float rate;//速率

@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
@property (nonatomic, copy, readonly) NSString *totalTimeFormat;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, copy, readonly) NSString *currentTimeFormat;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign, readonly) float loadDataProgress;//缓冲进度

@property (nonatomic, assign, readonly) WKAudioPlayerState state;

@end
