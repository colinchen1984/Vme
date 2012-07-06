//
//  VideoWeiBoDataManager.m
//  VmeDemo
//
//  Created by user on 12-5-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VideoWeiBoDataManager.h"
#import "SinaWeiBoSDK.h"

static VideoWeiBoDataManager* singleton = nil;
@interface VideoWeiBoDataManager()
@property (strong, nonatomic) NSMutableDictionary* videoWeiBoData;
@property (strong, nonatomic) NSMutableDictionary* weiBoUserData;
@end

@implementation VideoWeiBoDataManager
@synthesize videoWeiBoData = _videoWeiBoData;
@synthesize weiBoUserData = _weiBoUserData;

+ (VideoWeiBoDataManager*) sharedVideoWeiBoDataManager
{
	if (nil == singleton) 
	{
		singleton = [[VideoWeiBoDataManager alloc] init];
	}
	return  singleton;
}

- (id) init
{
	self = [super init];
	if (nil == self) 
	{
		return nil;
	}
	_weiBoUserData = [[NSMutableDictionary alloc] init];
	_videoWeiBoData = [[NSMutableDictionary alloc] init];
	return self;
}

- (void) addWeiBoUserPersonalInfo:(NSString*)weiboUserID UserPersonalInfo:(SinaWeiBoUserPersonalInfo*)userInfo
{
	SinaWeiBoUserPersonalInfo* weiBoUser = [self getWeiBoUserPersonalInfo:weiboUserID];
	if (nil != weiBoUser) 
	{
		return;
	}
	
	[_weiBoUserData setValue:userInfo forKey:weiboUserID];
}

- (SinaWeiBoUserPersonalInfo*) getWeiBoUserPersonalInfo:(NSString*)userID
{
	SinaWeiBoUserPersonalInfo* result = [_weiBoUserData objectForKey:userID];
	return result;
}

- (void) addVideoWeiBoData:(NSString*)videoID WeiBoData:(SinaWeiBoData*)weiBoData
{
	SinaWeiBoData* weiBo = [self getWeiBoDataByVideoID:videoID];
	if (nil != weiBo) 
	{
		return;
	}
	
	[_videoWeiBoData setValue:weiBoData forKey:videoID];
}

- (SinaWeiBoData*) getWeiBoDataByVideoID:(NSString*)videoID
{
	SinaWeiBoData* result = [_videoWeiBoData objectForKey:videoID];
	if (nil != result && nil == result.userInfo) 
	{
		result.userInfo = [self getWeiBoUserPersonalInfo:result.userID];
	}
	return result;
}

- (NSDictionary*) getAllWeiBoData
{
	return _videoWeiBoData;
}

- (void) addWeiBoComentByVideID:(NSString*)videoID Comments:(NSMutableArray*)comments
{
	SinaWeiBoData* weiBo = [self getWeiBoDataByVideoID:videoID];
	if (nil == weiBo) 
	{
		return;
	}
	if (nil == weiBo.comments) 
	{
		weiBo.comments = comments;
		[comments sortUsingSelector:@selector(compare:)];
	}
	else 
	{
		NSMutableArray* cs = (NSMutableArray*)weiBo.comments;
		[cs addObjectsFromArray:comments];
		[comments sortUsingSelector:@selector(compare:)];
	}
}

- (void) addWeiBoComentByVideID:(NSString*)videoID Comment:(SinaWeiBoComment*)comment
{
	SinaWeiBoData* weiBo = [self getWeiBoDataByVideoID:videoID];
	if (nil == weiBo) 
	{
		return;
	}
	if (nil == weiBo.comments) 
	{
		weiBo.comments = [[NSMutableArray alloc] initWithObjects:comment, nil];	
	}
	else 
	{
		NSMutableArray* cs = (NSMutableArray*)weiBo.comments;
		[cs addObject:comment];
		SinaWeiBoComment* w = [cs objectAtIndex:(cs.count - 2)];
		if (NSOrderedAscending == [comment.createTime compare:w.createTime]) 
		{
			[cs sortUsingSelector:@selector(compare:)];
		}
	}	
}

- (NSArray*) getWeiBoCommentsByVideoID:(NSString*)videoID
{
	SinaWeiBoData* weiBo = [self getWeiBoDataByVideoID:videoID];
	if (nil == weiBo) 
	{
		return nil;
	}
	return weiBo.comments;	
}

@end
