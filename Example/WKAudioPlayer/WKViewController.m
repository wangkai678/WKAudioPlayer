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

@end

@implementation WKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)play:(id)sender {
    [[WKAudioPlayer shareInstance] playerWithURL:[NSURL URLWithString:@""]];
}

- (IBAction)pause:(id)sender {
}

- (IBAction)resume:(id)sender {
}

- (IBAction)kuaijin:(id)sender {
}

- (IBAction)progress:(id)sender {
}

- (IBAction)rate:(id)sender {
}

- (IBAction)volume:(id)sender {
}



@end
