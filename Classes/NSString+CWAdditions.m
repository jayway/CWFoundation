//
//  NSString+CWPrefixAndSuffix.m
//  CWFoundation
//  Created by Fredrik Olsson 
//
//  Copyright (c) 2011, Jayway AB All rights reserved.
//  Copyright (c) 2012, Fredrik Olsson All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Jayway AB nor the names of its contributors may 
//       be used to endorse or promote products derived from this software 
//       without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL JAYWAY AB BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSString+CWAdditions.h"


@implementation NSString (CWPrefixAndSuffix)

-(NSUInteger)lengthOfCommonPrefixWithString:(NSString*)string;
{
    if (string == nil) {
    	return 0;
    }
	NSString* a = self;
    NSString* b = string;
    if ([a length] > [b length]) {
    	a = [a substringToIndex:[b length]];
    } else if ([b length] > [a length]) {
		b = [b substringToIndex:[a length]];        
    }
    NSUInteger length = 0;
    for (int i = 0; i < [a length]; i++) {
        if ([a characterAtIndex:i] != [b characterAtIndex:i]) {
        	break;
        }
        length++;
    }
    return length;
}

-(NSUInteger)lengthOfCommonSuffixWithString:(NSString*)string;
{
    if (string == nil) {
    	return 0;
    }
	NSString* a = self;
    NSString* b = string;
    if ([a length] > [b length]) {
    	a = [a substringFromIndex:[a length] - [b length]];
    } else if ([b length] > [a length]) {
		b = [b substringFromIndex:[b length] - [a length]];        
    }
    NSUInteger length = 0;
    for (int i = [a length] - 1; i >= 0; i--) {
        if ([a characterAtIndex:i] != [b characterAtIndex:i]) {
        	break;
        }
        length++;
    }
    return length;
}
-(NSRange)rangeOfNonCommonPrefixAndSuffixWithString:(NSString*)string;
{
    NSRange range = NSMakeRange(NSNotFound, 0);
	if (![self isEqualToString:string]) {
        range.location = [self lengthOfCommonPrefixWithString:string];
        NSString* trimmedSelf = [self substringFromIndex:range.location];
        NSString* trimmedString = [string substringFromIndex:range.location];
        NSUInteger length = [trimmedSelf lengthOfCommonSuffixWithString:trimmedString];
        range.length = [self length] - (range.location + length);
    }
    return range;
}

@end



@implementation NSString (CWUUID)

+(NSString*)randomUUIDString;
{
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef stringRef = CFUUIDCreateString(NULL, uuidRef);
    NSString* uuidString = [NSString stringWithString:(__bridge id)stringRef];
    CFRelease(stringRef);
    CFRelease(uuidRef);
    return uuidString;
}

-(BOOL)isUUIDString;
{
	CFUUIDRef uuidRef = CFUUIDCreateFromString(NULL, (__bridge CFStringRef)self);
    if (uuidRef) {
        CFRelease(uuidRef);
    	return YES;
    }
    return NO;   
}

@end
