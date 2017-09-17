//
//  WKAudioPlayer.m
//  Pods
//
//  Created by 王凯 on 17/9/17.
//
//

#import "WKAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface WKAudioPlayer ()

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
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    //监听播放状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }else {
            NSLog(@"状态未知");
        }
    }
}

@end
