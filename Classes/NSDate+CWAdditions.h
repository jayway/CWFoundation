//
//  NSDate+CWExtentions.h
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

#import <Foundation/Foundation.h>

/*!
 * @abstract A category on NSLocale adding support for ISO locales.
 */
@interface NSLocale (CWISOLocale) 

/*!
 * @abstract Get a locale mathcing the ISO standard.
 */
+(NSLocale*)ISOLocale;

@end


/*!
 * @abstract A cetegory on NSCalendar for accessing the Gregorian calender.
 */
@interface NSCalendar (CWGregorianCalendar)

/*!
 * @abstract Get a Gregorian calendar.
 */
+(NSCalendar*)gregorianCalendar;

@end

/*!
 * @abstract Category for working with proper ISO dates.
 */
@interface NSDate (CWISOAdditions)

/*!
 * @abstract Get a date from a string with a proper ISO date.
 */
+(NSDate*)dateWithISODateString:(NSString*)isoDate;

/*! @abstract Full ISO date, "2010-01-12". */
-(NSString*)ISODate;         

/*! @abstract Full ISO time, "13:52" */
-(NSString*)ISOTime;         

/*! @abstract Compact ISO date, "100112". */
-(NSString*)compactISODate;  

/*! @abstract Comapct ISO date, "1352". */
-(NSString*)compactISOTime;  

@end

/*!
 * @abstract Category for managing dates relative to the current date and time.
 */
@interface NSDate (CWRelativeDate)

/*!
 * @abstract Get a date that is relative to the current date and time.
 */
+(NSDate*)relativeDateWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;

/*!
 * @abstract The date and time as a localized string in short format.
 */
-(NSString*)localizedShortString;

/*!
 * @abstract The date as a localized string in short format.
 */
-(NSString*)localizedShortDateString;

/*!
 * @abstract The time as a localized string in short format.
 */
-(NSString*)localizedShortTimeString;

/*!
 * @abstract Query if date is relative to current date and time.
 */ 
-(BOOL)isRelativeDate;

@end