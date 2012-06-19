//
//  SinaWeiBoSDK+HandleData.m
//  VmeDemo
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaWeiBoSDK+HandleData.h"
#import "ImageManager.h"
#import "VideoWeiBoDataManager.h"

@implementation SinaWeiBoSDK (HandleData)

#pragma mark - private interface
- (SinaWeiBoData*) getWeiBoDataFromDic:(NSDictionary*)dic
{
	SinaWeiBoData* weiBo = [[SinaWeiBoData alloc] init];
	weiBo.weiBoID = [dic objectForKey:@"idstr"];
	weiBo.annotation = [dic objectForKey:@"annotations"];
	NSString* text = [dic objectForKey:@"text"];
	NSRange range = [text rangeOfString:@"http://t.cn/"];
	weiBo.text = NSNotFound != range.location ? [text substringToIndex:range.location] : text;
	weiBo.userID = [[dic objectForKey:@"user"] objectForKey:@"idstr"];
	weiBo.userInfo = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoUserPersonalInfo:weiBo.userID];
	return weiBo;
}


- (void) handlerUserPersonalInfo:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	NSString* userID = [dataDic objectForKey:@"idstr"];
	SinaWeiBoUserPersonalInfo* userPersonalInfo = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoUserPersonalInfo:userID];
	if (nil == userPersonalInfo) 
	{
		userPersonalInfo = [[SinaWeiBoUserPersonalInfo alloc] init];
		userPersonalInfo.userID = userID;
		userPersonalInfo.userName = [dataDic objectForKey:@"screen_name"];
		NSString* imageURL = [dataDic objectForKey:@"profile_image_url"];
		[[ImageManager sharedImageManager] postURL2DownLoadImage:imageURL Delegate:userPersonalInfo];
		[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addWeiBoUserPersonalInfo:userPersonalInfo.userID UserPersonalInfo:userPersonalInfo];
	}
	
	if ([delegate respondsToSelector:@selector(OnRecevieWeiBoUserPersonalInfo:)])
    {
        [delegate OnRecevieWeiBoUserPersonalInfo:userPersonalInfo];
    }
	
}

- (void) handlerSendWeiBoData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	SinaWeiBoData* weiBo = [self getWeiBoDataFromDic:dataDic];
	if(nil == weiBo)
	{
		return;
	}
	[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addVideoWeiBoData:[weiBo.annotation objectAtIndex:0] WeiBoData:weiBo];
	if ([delegate respondsToSelector:@selector(OnReceiveSendWeiBoResult:)])
    {
        [delegate OnReceiveSendWeiBoResult:weiBo];
    }
	
}


- (void) handlerGetWeiBoCommentsData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	NSArray* commentArray = [dataDic objectForKey:@"comments"];
	if (0 == [commentArray count]) 
	{
		return;
	}
	
	NSMutableArray* resultArray = nil;
	if ([delegate respondsToSelector:@selector(OnReceiveCommentForWeiBo: Comments:)])
    {
        resultArray = [[NSMutableArray alloc] initWithCapacity:[commentArray count]];
    }
	
	for (NSDictionary* dic in commentArray) 
	{
		SinaWeiBoComment* weiBoComment = [self getCommentFromDic:dic];
		[resultArray addObject:weiBoComment]; 
	}

	SinaWeiBoData* weiBoData = ((SinaWeiBoComment*)[resultArray objectAtIndex:0]).weiBoData;
	[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addWeiBoComentByVideID:[weiBoData.annotation objectAtIndex:0]  Comments:resultArray];
	if ([delegate respondsToSelector:@selector(OnReceiveCommentForWeiBo: Comments:)])
    {
        [delegate OnReceiveCommentForWeiBo:weiBoData Comments:resultArray];
    }
	
}

- (void) handlerBatchWeiBoComments:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	NSArray* array = (NSArray*)dataDic;
	for (NSDictionary* dic in array) 
	{
		SinaWeiBoComment* weiBoComment = [self getCommentFromDic:dic];
		SinaWeiBoData* weiBoData = weiBoComment.weiBoData;
		[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addWeiBoComentByVideID:[weiBoData.annotation objectAtIndex:0]  Comment:weiBoComment];
	}
	
}

- (void) handlerGetUserAllWeiBoData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	NSArray*	weiBoArray = [dataDic objectForKey:@"statuses"];
	NSMutableArray* resultArray = nil;
	if ([delegate respondsToSelector:@selector(OnReceiveUserAllWeiBo:)])
    {
        resultArray = [[NSMutableArray alloc] initWithCapacity:[weiBoArray count]];
    }
	for (NSDictionary* dic in weiBoArray)
	{
		SinaWeiBoData* weiBo = [self getWeiBoDataFromDic:dic];
		[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addVideoWeiBoData:[weiBo.annotation objectAtIndex:0] WeiBoData:weiBo];
		[resultArray addObject:weiBo];
	}
	if ([delegate respondsToSelector:@selector(OnReceiveUserAllWeiBo:)])
    {
        [delegate OnReceiveUserAllWeiBo:resultArray];
    }
}

- (SinaWeiBoComment*) getCommentFromDic:(NSDictionary*) dataDic
{
	SinaWeiBoComment* weiBoComment = [[SinaWeiBoComment alloc] init];
	weiBoComment.weiBoCommentID = [dataDic objectForKey:@"idstr"];
	weiBoComment.text = [dataDic objectForKey:@"text"];
	NSDictionary* userDataDic = [dataDic objectForKey:@"user"];
	NSString* userID = [userDataDic objectForKey:@"idstr"];
	SinaWeiBoUserPersonalInfo* userInfo = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoUserPersonalInfo:userID];
	if (nil == userInfo) 
	{
		userInfo = [[SinaWeiBoUserPersonalInfo alloc] init];
		userInfo.userName = [userDataDic objectForKey:@"screen_name"];
		userInfo.userID = userID;
		[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addWeiBoUserPersonalInfo:userID UserPersonalInfo:userInfo];
		NSString* imageURL = [userDataDic objectForKey:@"profile_image_url"];
		[[ImageManager sharedImageManager] postURL2DownLoadImage:imageURL Delegate:userInfo];
	}
	weiBoComment.userInfo = userInfo;
	NSDictionary* weiBoDic = [dataDic objectForKey:@"status"];
	NSArray* annotation = [weiBoDic objectForKey:@"annotations"];;
	SinaWeiBoData* weiBoData = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoDataByVideoID:[annotation objectAtIndex:0]];
	weiBoComment.weiBoData = weiBoData;
	return  weiBoComment;
}

- (void) handlerCreateWeiBoComent:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	SinaWeiBoComment* weiBoComment = [self getCommentFromDic:dataDic];
	if(nil == weiBoComment)
	{
		return;
	}
	[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addWeiBoComentByVideID:[weiBoComment.weiBoData.annotation objectAtIndex:0] Comment:weiBoComment];
	if ([delegate respondsToSelector:@selector(OnReceiveCommentReplyResult:)])
    {
        [delegate OnReceiveCommentReplyResult:weiBoComment];
    }	
}

- (void) handlerReplyCommentData:(NSDictionary*) dataDic Delegate:(id<SinaWeiBoSDKDelegate>)delegate
{
	SinaWeiBoComment* weiBoComment = [self getCommentFromDic:dataDic];
	if(nil == weiBoComment)
	{
		return;
	}
	[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addWeiBoComentByVideID:[weiBoComment.weiBoData.annotation objectAtIndex:0] Comment:weiBoComment];
	if ([delegate respondsToSelector:@selector(OnReceiveCommentReplyResult:)])
    {
        [delegate OnReceiveCommentReplyResult:weiBoComment];
    }
}

@end
