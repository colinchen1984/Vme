//
//  CommentView.h
//  VmeDemo
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommentView;

@protocol CommentViewDelegate <NSObject>
@optional
- (void) OnReplyCommentButtonClick:(CommentView*)commentView;
- (void) OnAvatarClick:(CommentView*)commentView;
@end

@interface CommentView : UIView
- (void) setPopDirection:(BOOL)isLeft;
- (void) setAvatarImage:(UIImage*)avatarImage;
- (void) settext:(NSString*)text;
@property (weak, nonatomic) id userData;
@property (weak, nonatomic) id<CommentViewDelegate> delegate;
@end
