//
//  SendWeiBoView.h
//  VmeDemo
//
//  Created by user on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SinaWeiBoSDK;
@class TudouVideoInfo;
@protocol SinaWeiBoSDKDelegate;

@interface SendWeiBoView : UIView
@property (weak, nonatomic) SinaWeiBoSDK* weiBoSDK;
@property (weak, nonatomic) TudouVideoInfo* videoInfo;
@property (weak, nonatomic) id<SinaWeiBoSDKDelegate> weiboDelegate;
- (void) Show:(BOOL)animated;
@end
