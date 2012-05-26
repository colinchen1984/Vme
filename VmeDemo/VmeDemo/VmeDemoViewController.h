//
//  VmeDemoViewController.h
//  VmeDemo
//
//  Created by user on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuDouSDK.h"
#import "SinaWeiBoSDK.h"
@interface VmeDemoViewController : UIViewController <TuDouSDKDelegate>
{
	int currentVideoIndex;
	int totalVideoCount;
	int totalPageCount;
	int currentPageNo;
}
@property (weak, nonatomic) TuDouSDK* tudouSDK;
@property (strong, nonatomic) NSString* tudouUserName;
@property (strong, nonatomic) SinaWeiBoSDK* sinaWeiBoSDK;
@end
