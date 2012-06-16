//
//  UIVideoView.h
//  VmeDemo
//
//  Created by user on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SinaWeiBoData;
@class TudouVideoInfo;
@class UIVideoView;
@class SinaWeiBoUserPersonalInfo;

@protocol UIVideoViewDelegate <NSObject>
@required
- (void) OnVideoImageClick:(UIVideoView*)view;
- (void) OnWeiBoCommentUserAvatarClick:(SinaWeiBoUserPersonalInfo*) userInfo;
@end

@interface UIVideoView : UIView
- (void) UpdateView;
@property (weak, nonatomic) SinaWeiBoData* weiBoData;
@property (weak, nonatomic) TudouVideoInfo* videoInfo;
@property (weak, nonatomic) id<UIVideoViewDelegate> videoViewDelegate;
@end
