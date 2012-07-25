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
- (void) OnReceiveImage:(UIImage*)image ImageUrl:(NSString*)imageUrl;
- (void) OnReceiveError:(NSString*)imageURL;
@end

@interface ImageManager : NSObject <WebRequestDelegate>
- (void) postURL2DownLoadImage:(NSString*) urlPath Delegate:(__weak id<URLImageDelegate>)delegate;

- (UIImage*) getImageFromBundle:(NSString*) fileName;

+ (ImageManager*) sharedImageManager;
@end
