//
//  NSCalendar+CWAdditions.m
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

#import "NSCalendar+CWAdditions.h"


@implementation NSCalendar (CWAdditions)

-(NSInteger)calendarUnit:(NSCalendarUnit)unit fromDate:(NSDate*)date;
{
    NSDateComponents* components = [self components:unit fromDate:date];
    switch (unit) {
        case NSEraCalendarUnit:     return [components era];
        case NSYearCalendarUnit:    return [components year];
        case NSQuarterCalendarUnit: return [components quarter];
        case NSMonthCalendarUnit:   return [components month];
        case NSWeekCalendarUnit:    return [components week];
        case NSDayCalendarUnit:     return [components day];
        case NSWeekdayCalendarUnit: return [components weekday];
        case NSHourCalendarUnit:    return [components hour];
        case NSMinuteCalendarUnit:  return [components minute];
        case NSSecondCalendarUnit:  return [components second];
        default:
            return NSUndefinedDateComponent;
    }
}

-(NSInteger)truncationMaskForCalendarUnit:(NSCalendarUnit)unit;
{
    NSInteger mask = 0;
    switch (unit) {
        // Intentionall fall-through for all cases.
        case NSSecondCalendarUnit:  mask |= NSSecondCalendarUnit;
        case NSMinuteCalendarUnit:  mask |= NSMinuteCalendarUnit;
        case NSHourCalendarUnit:    mask |= NSHourCalendarUnit;
        case NSDayCalendarUnit:     mask |= NSDayCalendarUnit;
        case NSWeekdayCalendarUnit: mask |= NSWeekdayCalendarUnit;
        case NSWeekCalendarUnit:    mask |= NSWeekCalendarUnit;
        case NSMonthCalendarUnit:   mask |= NSMonthCalendarUnit;
        case NSQuarterCalendarUnit: mask |= NSQuarterCalendarUnit;
        case NSYearCalendarUnit:    mask |= NSYearCalendarUnit;
        case NSEraCalendarUnit:     mask |= NSEraCalendarUnit;
            return mask;
        default:
            return NSUndefinedDateComponent;
    }    
}

-(NSDate*)truncateDate:(NSDate*)date toCalendarUnit:(NSCalendarUnit)unit;
{
    NSInteger mask = [self truncationMaskForCalendarUnit:unit];
        NSAssert(mask != 0, @"Unsupported calendar unit for truncation %d", unit);
    NSDateComponents* components = [self components:mask fromDate:date];
    return [self dateFromComponents:components];
}

-(NSComparisonResult)compareDate:(NSDate*)dateA toDate:(NSDate*)dateB withCalendarUnitPrecision:(NSCalendarUnit)unit;
{
    dateA = [self truncateDate:dateA toCalendarUnit:unit];
    dateB = [self truncateDate:dateB toCalendarUnit:unit];
    return [dateA compare:dateB];
}

@end
