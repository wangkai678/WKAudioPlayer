//
//  WKAudioDownLoader.h
//  Pods
//
//  Created by wangkai on 2017/9/21.
//
//

#import <Foundation/Foundation.h>

@protocol WKAudioDownLoaderDelegate <NSObject>

- (void)downLoading;

@end

@interface WKAudioDownLoader : NSObject

@property (nonatomic, weak) id <WKAudioDownLoaderDelegate> delegate;
@property (nonatomic ,assign) long long loadedSize;
@property (nonatomic ,assign) long long offset;
@property (nonatomic ,assign) long long totalSize;
@property (nonatomic ,strong) NSString *mimeType;


- (void)downLoadwithURL:(NSURL *)url offset:(long long)offset;

@end
