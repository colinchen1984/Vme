//
//  WebRequest.h
//  VmeDemo
//
//  Created by user on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WebRequest;
@protocol WebRequestDelegate
- (void) OnReceiveData:(WebRequest*) request Data:(NSData*)data;
- (void) OnReceiveError:(WebRequest*) request;
@end

@interface WebRequest : NSObject
@property (weak, nonatomic) id<WebRequestDelegate> delegate;
@property (strong, nonatomic) NSString* httpMethod;
@property (strong, nonatomic) NSDictionary* httpBody;
@property (strong, nonatomic) NSDictionary* httpHeader;

- (void) postUrlRequest:(NSString*) url;
- (void) cancelRequest;
@end

