//
//  ImageManager.h
//  VmeDemo
//
//  Created by user on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRequest.h"
@protocol URLImageDelegate
- (void) OnReceiveImage:(UIImage*)image;
- (void) OnReceiveError:(NSString*)imageURL;
@end

@interface ImageManager : NSObject <WebRequestDelegate>
- (void) postURL2DownLoadImage:(NSString*) urlPath Delegate:(__weak id<URLImageDelegate>)delegate;

- (void) cancelURLDownLoadImage:(NSString*) urlPath;

- (UIImage*) getImageFromBundle:(NSString*) fileName;

+ (ImageManager*) sharedImageManager;
@end
