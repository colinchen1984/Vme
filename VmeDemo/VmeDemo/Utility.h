//
//  Utility.h
//  VmeDemo
//
//  Created by user on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//Functions for Encoding Data.
@interface NSData (WBEncode)
- (NSString *)MD5EncodedString;
- (NSString *)base64EncodedString;
@end

//Functions for Encoding String.
@interface NSString (WBEncode)
- (NSString *)MD5EncodedString;
- (NSString *)base64EncodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;
@end

extern bool Base64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize);

#define GlobalBackGroundColor [UIColor colorWithRed:239.0f / 256.0f green:239.0f / 256.0f  blue:239.0f / 256.0f  alpha:1.0f]