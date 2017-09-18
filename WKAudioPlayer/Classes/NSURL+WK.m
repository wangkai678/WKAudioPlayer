//
//  NSURL+WK.m
//  Pods
//
//  Created by 王凯 on 17/9/18.
//
//

#import "NSURL+WK.h"

@implementation NSURL (WK)

- (NSURL *)streamingURL {
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"streaming";
    return compents.URL;
}

@end
