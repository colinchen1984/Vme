//
//  VideoDetailViewController.h
//  VmeDemo
//
//  Created by user on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageManager.h"
@class TudouVideoInfo;
@class SinaWeiBoSDK;
@interface VideoDetailViewController : UIViewController <URLImageDelegate>
@property (weak, nonatomic) TudouVideoInfo* videoInfo;
@property (weak, nonatomic) SinaWeiBoSDK* sinaWeiBoSDK;
@end
