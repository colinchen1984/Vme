//
//  Utility.m
//  VmeDemo
//
//  Created by user on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Utility.h"
#import <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"

@implementation NSData (WBEncode)

- (NSString *)MD5EncodedString
{
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], [self length], result);
	
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}


- (NSString *)base64EncodedString
{
	return [GTMBase64 stringByEncodingData:self];
}

@end

#pragma mark - NSString (WBEncode)

@implementation NSString (WBEncode)

- (NSString *)MD5EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5EncodedString];
}


- (NSString *) base64EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
	CFStringRef param = (__bridge CFStringRef)self;
	CFStringRef fitle = CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/");
	CFStringRef ret =  CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  param, NULL, fitle, encoding);
	return (__bridge_transfer NSString *)ret;
}

- (NSString *)URLEncodedString
{
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}


@end