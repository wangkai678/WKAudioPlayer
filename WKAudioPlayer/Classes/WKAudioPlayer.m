//
//  WKAudioPlayer.m
//  Pods
//
//  Created by 王凯 on 17/9/17.
//
//

#import "WKAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface WKAudioPlayer () {
    BOOL _isUserPause;
}

@property(nonatomic,strong)AVPlayer *player;

@end

@implementation WKAudioPlayer

static WKAudioPlayer *_shareInstance;
+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[WKAudioPlayer alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (void)playerWithURL:(NSURL *)url {
    NSURL *currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([url isEqual:currentURL]) {
        NSLog(@"当前播放任务已经存在");
        [self resume];
        return;
    }
    
    _url = url;
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    if (self.player.currentItem) {
        [self removeObserver];
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    //监听播放状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    self.player = [AVPlayer playerWithPlayerItem:item];
}

- (void)pause {
    [self.player pause];
    _isUserPause = YES;
    if (self.player) {
        self.state = WKAudioPlayerStatePause;
    }
}

- (void)resume {
    [self.player play];
    _isUserPause = NO;
    //当前播放器存在，并且数据组织者里面的数据准备已经足够可以播放了
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = WKAudioPlayerStatePlaying;
    }
}

- (void)stop {
    [self.player pause];
    self.player = nil;
    if (self.player) {
        self.state = WKAudioPlayerStateStopped;
    }
}

- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    //当前音频资源的总时长
    NSTimeInterval totalTimeSec = self.totalTime;
    //当前播放的时长
    NSTimeInterval playTimeSec = self.currentTime;
    playTimeSec += timeDiffer;
    
    [self seekWithTimeProgress:playTimeSec / totalTimeSec];
}

- (void)seekWithTimeProgress:(float)progress {
    
    if (progress < 0 || progress > 1) {
        return;
    }
    
    //1.当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSec = totalSec * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点的音频资源");
        }else{
            //连续拖动进度条，上一次加载会被取消
            NSLog(@"取消加载这个歌时间点的音频资源");
        }
    }];
}

- (void)setRate:(float)rate {
    [self.player setRate:rate];
}

- (float)rate {
    return self.player.rate;
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

-  (BOOL)muted {
    return self.player.muted;
}

- (void)setVolume:(float)volume {
    if (volume < 0 || volume > 1) {
        return;
    }
    if (volume > 0) {
        [self setMuted:NO];
    }
    self.player.volume = volume;
}

- (float)volume {
    return self.player.volume;
}

- (NSString *)currentTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.currentTime / 60,(int)self.currentTime % 60];
}

- (NSString *)totalTimeFormat {
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.totalTime / 60,(int)self.totalTime % 60];
}

#pragma mark - 

- (NSTimeInterval)totalTime {
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    if (isnan(totalSec)) {
        return 0;
    }
    return totalSec;
}

- (NSTimeInterval)currentTime {
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}

- (float)progress {
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}

- (float)loadDataProgress {
    if (self.totalTime == 0) {
        return 0;
    }
   CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
   CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    return loadTimeSec / self.totalTime;
}

- (void)setState:(WKAudioPlayerState)state {
    _state = state;
}

#pragma mark - 事件
//播放完成的通知
- (void)playEnd {
    NSLog(@"播放完成");
    self.state = WKAudioPlayerStateStopped;
}
//播放被打断
- (void)playInterupt {
    //来电话了，资源加载跟不上了
    NSLog(@"播放被打断");
    self.state = WKAudioPlayerStatePause;
}

#pragma mark - KVO
- (void)removeObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            [self resume];
        }else {
            NSLog(@"状态未知");
            self.state = WKAudioPlayerStateFailed;
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL playbackLikelyToKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
        if (playbackLikelyToKeepUp) {
            if (!_isUserPause) {
                [self resume];
            }else{
                
            }
            NSLog(@"当前的资源准备的已经足够可以播放了");
        }else{
            NSLog(@"资源还不够，正在加载过程中");
            self.state = WKAudioPlayerStateLoading;
        }
    }
}

@end
