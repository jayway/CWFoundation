//
//  NSDate+CWExtentions.m
//  CWFoundation
//  Created by Fredrik Olsson 
//
//  Copyright (c) 2011, Jayway AB All rights reserved.
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

#import "NSDate+CWAdditions.h"

@implementation NSLocale (CWISOLocale) 

+(NSLocale*)ISOLocale;
{
	static NSLocale* isoLocale = nil;
    @synchronized(self) {
        // Sweden is close enough for ISO.
        isoLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"];
    }
    return isoLocale;
}

@end


@implementation NSCalendar (CWGregorianCalendar)

+(NSCalendar*)gregorianCalendar;
{
	static NSCalendar* gregorianCalendar = nil;
    @synchronized(self) {
        if (gregorianCalendar == nil) {
            gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        }
    }
    return gregorianCalendar;
}

@end


@implementation NSDate (CWISOAdditions)

+(NSDate*)dateWithISODateString:(NSString*)isoDate;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized(self) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
            [dateFormatter setLocale:[NSLocale ISOLocale]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        }
    }
    return [dateFormatter dateFromString:isoDate];
}

-(NSString*)ISODate;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized([self class]) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
            [dateFormatter setLocale:[NSLocale ISOLocale]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
    }
    return [dateFormatter stringFromDate:self];
}

-(NSString*)ISOTime;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized([self class]) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
            [dateFormatter setLocale:[NSLocale ISOLocale]];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
        }
    }
    return [dateFormatter stringFromDate:self];
}

-(NSString*)compactISODate;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized([self class]) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
            [dateFormatter setLocale:[NSLocale ISOLocale]];
            [dateFormatter setDateFormat:@"yyMMdd"];
        }
    }
    return [dateFormatter stringFromDate:self];
}

-(NSString*)compactISOTime;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized([self class]) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
            [dateFormatter setLocale:[NSLocale ISOLocale]];
            [dateFormatter setDateFormat:@"HHmm"];
        }
    }
    return [dateFormatter stringFromDate:self];
}

@end

@interface CWRelativeDate : NSDate {
@private
    NSTimeInterval _timeIntervalSinceNow;
}

-(instancetype)initWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval NS_DESIGNATED_INITIALIZER;

@end

@implementation CWRelativeDate

-(instancetype)initWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;
{
    self = [super init];
    if (self) {
        _timeIntervalSinceNow = timeInterval;
    }
    return self;
}

-(Class)classForCoder;
{
    return [self class];
}

-(instancetype)initWithCoder:(NSCoder*)aDecoder;
{
    self = [super init];
    if (self) {
        _timeIntervalSinceNow = [aDecoder decodeDoubleForKey:@"timeIntervalSinceNow"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)aCoder;
{
    [aCoder encodeDouble:_timeIntervalSinceNow forKey:@"timeIntervalSinceNow"];
}

-(NSTimeInterval)timeIntervalSinceNow;
{
	return _timeIntervalSinceNow;  
}

-(NSTimeInterval)timeIntervalSinceReferenceDate;
{
    return [[NSDate date] timeIntervalSinceReferenceDate] + _timeIntervalSinceNow;
}


-(NSString*)localizedShortString;
{
    NSString* key = nil;
    if (_timeIntervalSinceNow == 0.0) {
        key = @"Now";
    } else if (_timeIntervalSinceNow == 60.0 * 15) {
        key = @"QuarterHour";
    } else if (_timeIntervalSinceNow == 60.0 * 30) {
        key = @"HalfHour";
    } else if (_timeIntervalSinceNow == 60.0 * 60) {
        key = @"Hour";
    } else {
        // TODO: This is no good, since a relative time is constantly moving in time.
        return [super localizedShortString];
    }
    return NSLocalizedString(key, nil);
}

-(BOOL)isRelativeDate;
{
    return YES;
}

-(BOOL)isEqualToDate:(NSDate *)otherDate;
{
	if ([otherDate isKindOfClass:[CWRelativeDate class]]) {
        return _timeIntervalSinceNow == ((CWRelativeDate*)otherDate)->_timeIntervalSinceNow;
    } else {
		return [super isEqualToDate:otherDate];    
    }
}

@end


@implementation NSDate (CWRelativeDate)

+(NSDate*)relativeDateWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;
{
    return [[[CWRelativeDate alloc] initWithTimeIntervalSinceNow:timeInterval] autorelease];
}

-(NSString*)localizedShortString;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized([self class]) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
    }
    return [dateFormatter stringFromDate:self];
}


-(NSString*)localizedShortDateString;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized([self class]) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }
    }
    return [dateFormatter stringFromDate:self];
}

-(NSString*)localizedShortTimeString;
{
    static NSDateFormatter* dateFormatter = nil;
    @synchronized([self class]) {
        if (dateFormatter == nil) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
    }
    return [dateFormatter stringFromDate:self];
}

-(BOOL)isRelativeDate;
{
    return NO;
}

@end