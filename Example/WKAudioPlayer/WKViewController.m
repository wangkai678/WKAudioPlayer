//
//  WKViewController.m
//  WKAudioPlayer
//
//  Created by wangkai_678@163.com on 09/16/2017.
//  Copyright (c) 2017 wangkai_678@163.com. All rights reserved.
//

#import "WKViewController.h"
#import "WKAudioPlayer.h"

@interface WKViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *loadPV;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIButton *mutedBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;



@property (nonatomic, weak) NSTimer *timer;
@end

@implementation WKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self timer];
}

- (NSTimer *)timer {
    if (!_timer) {
       NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

- (void)update {
    NSLog(@"%zd",[WKAudioPlayer shareInstance].state);
    self.playTimeLabel.text = [[WKAudioPlayer shareInstance] currentTimeFormat];
    self.totalTimeLabel.text = [[WKAudioPlayer shareInstance] totalTimeFormat];
    self.playSlider.value = [[WKAudioPlayer shareInstance] progress];
    self.loadPV.progress = [WKAudioPlayer shareInstance].loadDataProgress;
    self.mutedBtn.selected = [WKAudioPlayer shareInstance].muted;
    self.volumeSlider.value = [WKAudioPlayer shareInstance].volume;
}

- (IBAction)play:(id)sender {
    [[WKAudioPlayer shareInstance] playerWithURL:[NSURL URLWithString:@"http://www.0772music.cn/uploadfiles/article/admin/2008-12/2008122309035034344.mp3"] isCache:YES];
}

- (IBAction)pause:(id)sender {
    [[WKAudioPlayer shareInstance] pause];
}

- (IBAction)resume:(id)sender {
    [[WKAudioPlayer shareInstance] resume];
}

- (IBAction)kuaijin:(id)sender {
    [[WKAudioPlayer shareInstance] seekWithTimeDiffer:15];
}

- (IBAction)progress:(UISlider *)sender {
    [[WKAudioPlayer shareInstance] seekWithTimeProgress:sender.value];
}

- (IBAction)rate:(id)sender {
    [[WKAudioPlayer shareInstance] setRate:2];
}

- (IBAction)muted:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[WKAudioPlayer shareInstance] setMuted:sender.selected];
}

- (IBAction)volume:(UISlider *)sender {
    [[WKAudioPlayer shareInstance] setVolume:sender.value];
}



@end
