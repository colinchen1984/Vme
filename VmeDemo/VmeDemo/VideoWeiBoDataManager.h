//
//  VideoWeiBoDataManager.h
//  VmeDemo
//
//  Created by user on 12-5-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SinaWeiBoData;
@class SinaWeiBoUserPersonalInfo;
@class SinaWeiBoComment;

@interface VideoWeiBoDataManager : NSObject
- (void) addWeiBoUserPersonalInfo:(NSString*)weiboUserID UserPersonalInfo:(SinaWeiBoUserPersonalInfo*)userInfo;

- (SinaWeiBoUserPersonalInfo*) getWeiBoUserPersonalInfo:(NSString*)userID;

//videoId是土豆提供的视频的id
- (void) addVideoWeiBoData:(NSString*)videoID WeiBoData:(SinaWeiBoData*)weiBoData;

- (SinaWeiBoData*) getWeiBoDataByVideoID:(NSString*)videoID;

- (void) addWeiBoComentByVideID:(NSString*)videoID Comments:(NSMutableArray*)comments;

- (void) addWeiBoComentByVideID:(NSString*)videoID Comment:(SinaWeiBoComment*)comment;

- (NSArray*) getWeiBoCommentsByVideoID:(NSString*)videoID;

+ (VideoWeiBoDataManager*) sharedVideoWeiBoDataManager;
@end
