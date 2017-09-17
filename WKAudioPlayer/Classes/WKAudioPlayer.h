//
//  WKAudioPlayer.h
//  Pods
//
//  Created by 王凯 on 17/9/17.
//
//

#import <Foundation/Foundation.h>

@interface WKAudioPlayer : NSObject

+ (instancetype)shareInstance;

- (void)playerWithURL:(NSURL *)url;

@end
