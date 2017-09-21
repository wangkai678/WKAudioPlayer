//
//  WKAudioDownLoader.h
//  Pods
//
//  Created by wangkai on 2017/9/21.
//
//

#import <Foundation/Foundation.h>

@interface WKAudioDownLoader : NSObject

@property (nonatomic ,assign) long long loadedSize;

- (void)downLoadwithURL:(NSURL *)url offset:(long long)offset;

@end
