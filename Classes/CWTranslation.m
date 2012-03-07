//
//  CWTranslation.m
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

#import "CWTranslation.h"
#import "CWTranslatorPrivate.h"

NSString* const CWTranslationRootMarker = @"@root";

@interface NSCharacterSet (CWXMLTranslation)

+(NSCharacterSet*)validSymbolChararactersSet;
+(NSCharacterSet*)validKeyPathSymbolChararactersSet;
+(NSCharacterSet*)validXMLSymbolChararactersSet;

@end

@interface CWTranslationParser : NSObject {
@private
	NSMutableArray* _nameStack;
}

-(CWTranslation*)parseTranslationFromScanner:(NSScanner*)scanner;
-(CWTranslation*)translationNamed:(NSString*)name;

@end

@implementation CWTranslationParser

#pragma mark --- Object life cycle

-(id)init;
{
	self = [super init];
    if (self) {
    	_nameStack = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

#pragma mark --- Private helpers

-(NSScanner*)scannerWithTranslationNamed:(NSString*)name;
{
	NSString* type = [name pathExtension];
    if ([type length] == 0) {
    	type = @"translation";
    }
    name = [name stringByDeletingPathExtension];
    NSBundle *bundle = [CWTranslation translationBundle];
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
	NSString* path = [bundle pathForResource:name 
                                      ofType:type];
    if (!path) {
        [NSException raise:NSInvalidArgumentException
                    format:@"CWXMLTranslation could not find translation file %@", name];
    } else {
        NSString* string = [NSString stringWithContentsOfFile:path 
                                                     encoding:NSUTF8StringEncoding 
                                                        error:NULL];
        if (!string) {
            [NSException raise:NSInvalidArgumentException
                        format:@"CWXMLTranslation could read contents of translation file %@", name];
        } else {
            NSScanner* scanner = [NSScanner scannerWithString:string];
            [scanner setCharactersToBeSkipped:nil];
            return scanner;
        }
    }
    return nil;
}

-(NSString*)stringWithLocationInScanner:(NSScanner*)scanner;
{
	NSString* string = [[scanner string] substringToIndex:[scanner scanLocation]];
    NSArray* temp = [string componentsSeparatedByString:@"\n"];
    int line = [temp count];
    int col = [[temp lastObject] length];
    NSLog(@"line %d character %d in %@", line, col, [_nameStack lastObject]);
    return [NSString stringWithFormat:@"line %d character %d in %@", line, col, [_nameStack lastObject]];
}

-(void)skipShiteSpaceAndCommentsInScanner:(NSScanner*)scanner;
{
	[scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                        intoString:NULL];
    while ([scanner scanString:@"#" intoString:NULL]) {
    	[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
    }
}

-(BOOL)tryString:(NSString*)string fromScanner:(NSScanner*)scanner;
{
    [self skipShiteSpaceAndCommentsInScanner:scanner];
	return [scanner scanString:string intoString:NULL];
}

-(BOOL)takeString:(NSString*)string fromScanner:(NSScanner*)scanner;
{
	BOOL result = [self tryString:string fromScanner:scanner];
    if (!result) {
        [NSException raise:NSInvalidArgumentException
                    format:@"CWTranslation expected '%@' at %@", string, [self stringWithLocationInScanner:scanner]];
    }
    return result;
}

-(NSString*)takeSymbolFromScanner:(NSScanner*)scanner;
{
	[self skipShiteSpaceAndCommentsInScanner:scanner];
    NSString* symbol = nil;
    [scanner scanCharactersFromSet:[NSCharacterSet validSymbolChararactersSet] intoString:&symbol];
    if ([symbol length] == 0) {
        symbol = nil;
        [NSException raise:NSInvalidArgumentException
                    format:@"CWTranslation expected valid symbol at %@", [self stringWithLocationInScanner:scanner]];
    }
    return symbol;
}

-(NSString*)takeKeyPathSymbolFromScanner:(NSScanner*)scanner;
{
	[self skipShiteSpaceAndCommentsInScanner:scanner];
    NSString* symbol = nil;
    [scanner scanCharactersFromSet:[NSCharacterSet validKeyPathSymbolChararactersSet] intoString:&symbol];
    if ([symbol length] == 0) {
        symbol = nil;
        [NSException raise:NSInvalidArgumentException
                    format:@"CWTranslation expected valid key path symbol at %@", [self stringWithLocationInScanner:scanner]];
    }
    return symbol;
}

-(NSString*)takeXMLSymbolFromScanner:(NSScanner*)scanner;
{
	[self skipShiteSpaceAndCommentsInScanner:scanner];
    NSString* symbol = nil;
    [scanner scanCharactersFromSet:[NSCharacterSet validXMLSymbolChararactersSet] intoString:&symbol];
    if ([symbol length] == 0) {
        symbol = nil;
        [NSException raise:NSInvalidArgumentException
                    format:@"CWTranslation expected valid XML symbol at %@", [self stringWithLocationInScanner:scanner]];
    }
    return symbol;
}

#pragma mark --- Parse methods

-(BOOL)parseTypeFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
    NSString* type = [self takeSymbolFromScanner:scanner];
    Class destClass = NSClassFromString(type);
    if (destClass) {
        translation.destinationClass = destClass;
        return YES;
    }
    [NSException raise:NSInvalidArgumentException
                format:@"CWTranslation expected existing class %@ at %@", type, [self stringWithLocationInScanner:scanner]];
    return NO;
}

- (BOOL)parseTypeTransformerFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
    NSString* transformerName = [self takeSymbolFromScanner:scanner];
    if (transformerName) {
        translation.transformerName = transformerName;
        return [self takeString:@")" fromScanner:scanner];
    }
    return NO;
}

/*
 * type 	::= SYMBOL	["(" SYMBOL ")"]			# Type is a known Objective-C class (NSNumber, NSDate, NSURL)
 *				SYMBOL translation |				# Type is an Objective-C class with  inline translation definition
 *		 		"@" SYMBOL							# Type is an Objective-C class with translation defiition in external class
 */
-(BOOL)parseTypedAssignActionFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
    CWTranslation* subTranslation = nil;
	if ([self tryString:@"@" fromScanner:scanner]) {
        if ([self parseTypeFromScanner:scanner intoTranslation:translation]) {
            subTranslation = [self translationNamed:NSStringFromClass(translation.destinationClass)];
        }
    } else if ([self parseTypeFromScanner:scanner intoTranslation:translation]) {
        if ([self tryString:@"{" fromScanner:scanner]) {
            [scanner setScanLocation:[scanner scanLocation] - 1];
            subTranslation = [self parseTranslationFromScanner:scanner];
        } else if ([self tryString:@"(" fromScanner:scanner]) {
            return [self parseTypeTransformerFromScanner:scanner intoTranslation:translation];
        } else {
        	return YES;
        }
    }
    if (subTranslation) {
        translation.subTranslations = subTranslation.subTranslations;
        return YES;
    }
    return NO;
}

/*
 *  context     ::= "(" SYMBOL ")"
 */
-(BOOL)parseContextFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
    if ([self tryString:@"(" fromScanner:scanner]) {
        NSString* context = [self takeSymbolFromScanner:scanner];
        if (context && [self takeString:@")" fromScanner:scanner]) {
            translation.context = context;
            return YES;
        } else {
            return NO;
        }
    }    
    return YES;
}

/*
 *	target 		::= "@root" |							# Target is the array of root objects to return.
 *					SYMBOL								# Target is a named property accessable using setValue:forKeyPath:
 */
-(BOOL)parseAssignActionFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
    NSString* target = [self tryString:@"@root" fromScanner:scanner] ? CWTranslationRootMarker : [self takeKeyPathSymbolFromScanner:scanner];
    if (target) {
        translation.destinationKeyPath = target;
        if ([self parseContextFromScanner:scanner intoTranslation:translation]) {
            if ([self tryString:@":" fromScanner:scanner]) {
                return [self parseTypedAssignActionFromScanner:scanner intoTranslation:translation];
            } else {
                translation.destinationClass = [NSString class];
                return YES;
            }
        }
    }
    return NO;
}

/*
 *	assignment 	::= ">>" |								# Assign to target using setValue:forKeyPath:
 *					"+>"								# Append to target using addValue:forKeyPath:
 */
-(BOOL)parseAssignmentFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
    if ([self tryString:@"+>" fromScanner:scanner]) {
        translation.action = CWTranslationActionAppend;
        return YES;
    } else if ([self takeString:@">>" fromScanner:scanner]) {
        translation.action = CWTranslationActionAssign;
        return YES;
    }
    return NO;
}

/*
 *	action 		::= "->" translation |					# -> Is a required tag to descend into, but take no action on.
 *					assignment target { context } { ":" type }		# All other actions are assignment to a target, with optional context and type (NSString is used for untyped actions)
 */
-(BOOL)parseActionFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
	if ([self tryString:@"->" fromScanner:scanner]) {
        translation.action = CWTranslationActionRequire;
        CWTranslation* subTranslation = [self parseTranslationFromScanner:scanner];
        if (subTranslation) {
            if (subTranslation.sourceNames) {
                translation.subTranslations = [NSMutableSet setWithObject:subTranslation];
            } else {
                translation.subTranslations = subTranslation.subTranslations;
            }
            return YES;
        }
    } else {
        if ([self parseAssignmentFromScanner:scanner intoTranslation:translation]) {
	        return [self parseAssignActionFromScanner:scanner intoTranslation:translation];
        }
    }
    return NO;
}

/*
 *	statement 	::= { "." } SYMBOL action { ";" }		# A statement is an XML symbol with an action (prefix . is attributes).
 */
-(BOOL)parseStatementFromScanner:(NSScanner*)scanner intoTranslation:(CWTranslation*)translation;
{
    translation.valueSourceNames = [NSMutableSet setWithCapacity:1];
    translation.attributeSourceNames = [NSMutableSet setWithCapacity:1];
    do {
        BOOL isAttr = [self tryString:@"." fromScanner:scanner];
        NSString* symbol = [self tryString:@"@root" fromScanner:scanner] ? CWTranslationRootMarker : [self takeXMLSymbolFromScanner:scanner];
        if (symbol) {
            if (isAttr) {
                [translation.attributeSourceNames addObject:symbol];
            } else {
                [translation.valueSourceNames addObject:symbol];
            }
        } else {
            return NO;
        }
    } while ([self tryString:@"|" fromScanner:scanner]);
    if ([self parseActionFromScanner:scanner intoTranslation:translation]) {
        [self tryString:@";" fromScanner:scanner];
        return YES;
    }
    return NO;
}

/*
 *	translation ::= statement |							# A translation is one or more statement
 *					"{" statement* "}"
 */
-(CWTranslation*)parseTranslationFromScanner:(NSScanner*)scanner;
{
    CWTranslation* translation = [[CWTranslation alloc] init];
    if ([self tryString:@"{" fromScanner:scanner]) {
        translation.subTranslations = [NSMutableSet setWithCapacity:8];
		while (![self tryString:@"}" fromScanner:scanner]) {
            CWTranslation* subTranslation = [self parseTranslationFromScanner:scanner];
            if (subTranslation) {
                [(id)translation.subTranslations addObject:subTranslation];
            } else {
            	translation = nil;
                break;
            }
    	}
    } else {
    	if (![self parseStatementFromScanner:scanner intoTranslation:translation]) {
            translation = nil;
 	   	}
    }
    return translation;
}

#pragma mark --- Top level type entry point.

-(CWTranslation*)translationNamed:(NSString*)name;
{
    static NSMutableDictionary* translationCache = nil;
    CWTranslation* result = [translationCache objectForKey:name];
    if (result == nil) {
        NSString* pathExtension = [name pathExtension];
        if ([pathExtension length] == 0 || [pathExtension isEqualToString:@"translation"]) {
            NSScanner* scanner = [self scannerWithTranslationNamed:name];
            [_nameStack addObject:name];
            if (scanner) {
                result = [self parseTranslationFromScanner:scanner];
            }
            [_nameStack removeLastObject];
        } else {
            NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:[name stringByDeletingPathExtension]
                                                                              ofType:[name pathExtension]];
            result = [NSDictionary dictionaryWithContentsOfFile:path];
			NSLog(@"Translation path: %@",path);
        }
        if (result) {
        	if (translationCache == nil) {
            	translationCache = [[NSMutableDictionary alloc] initWithCapacity:8];
            }
            [translationCache setObject:result forKey:name];
        }
    }
    return result;
}

@end

@implementation CWTranslation

-(NSSet*)sourceNames;
{
    return [_valueSourceNames setByAddingObjectsFromSet:_attributeSourceNames];
}

@synthesize valueSourceNames = _valueSourceNames;
@synthesize attributeSourceNames = _attributeSourceNames;
@synthesize action = _action;
@synthesize destinationKeyPath = _destinationKey;
@synthesize destinationClass = _destinationClass;
@synthesize transformerName = _transformerName;
@synthesize context = _context;
@synthesize subTranslations = _subTranslations;

static NSBundle *translationBundle = nil;

+ (NSBundle*)translationBundle;
{
    return translationBundle;
}

+ (void)setTranslationBundle:(NSBundle*)bundle;
{
    translationBundle = bundle;
}


+(CWTranslation*)translationNamed:(NSString*)name;
{
    CWTranslationParser* temp = [[CWTranslationParser alloc] init];
    return [temp translationNamed:name];
}

+(CWTranslation*)translationWithDSLString:(NSString*)dslString;
{
    CWTranslationParser* temp = [[CWTranslationParser alloc] init];
	NSScanner* scanner = [NSScanner scannerWithString:dslString];
    [scanner setCharactersToBeSkipped:nil];
    return [temp parseTranslationFromScanner:scanner];
}

-(NSString*)description;
{
    NSString* s = @"";
    NSString* prefix = @"";
    for (NSString* name in self.valueSourceNames) {
        s = [s stringByAppendingFormat:@"%@%@", prefix, name];
        prefix = @"|";
    }
    for (NSString* name in self.attributeSourceNames) {
        s = [s stringByAppendingFormat:@"%@.%@", prefix, name];
        prefix = @"|";
    }
    switch (self.action) {
        case CWTranslationActionRequire:
            s = [s stringByAppendingString:@" ->"];
            break;
        case CWTranslationActionAssign:
            s = [s stringByAppendingFormat:@" >>"];
            break;
        case CWTranslationActionAppend:
            s = [s stringByAppendingFormat:@" +>"];
            break;
    }
    if (self.destinationKeyPath) {
        if (self.context) {
            s = [s stringByAppendingFormat:@" %@ (%@) : %@", self.destinationKeyPath, self.context, NSStringFromClass(self.destinationClass)];
        } else {
            s = [s stringByAppendingFormat:@" %@ : %@", self.destinationKeyPath, NSStringFromClass(self.destinationClass)];
        }
    }
    if (self.subTranslations) {
        s = [s stringByAppendingString:@" {"];
        for (CWTranslation* t in self.subTranslations) {
            s = [s stringByAppendingFormat:@" %@", [t description]];
        }
        s = [s stringByAppendingString:@" }"];
    } else {
        s = [s stringByAppendingString:@"; "];
    }
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(CWTranslation*)subTranslationForSourceName:(NSString*)name type:(CWTranslationSourceType)type;
{
    for (CWTranslation* translation in _subTranslations) {
        BOOL match = NO;
        switch (type) {
            case CWTranslationSourceTypeAny:
                match = [translation.sourceNames containsObject:name];
                break;
            case CWTranslationSourceTypeValue:
                match = [translation.valueSourceNames containsObject:name];
                break;
            case CWTranslationSourceTypeAttribute:
                match = [translation.attributeSourceNames containsObject:name];
                break;
        }
        if (match) {
            return translation;
        }
    }
    return nil;
}

-(BOOL)isAtomic;
{
    return _subTranslations == nil;
}

@end


@implementation NSCharacterSet (CWXMLTranslation)

+(NSCharacterSet*)validSymbolChararactersSet;
{
	static NSCharacterSet* characterSet = nil;
    if (characterSet == nil) {
    	NSMutableCharacterSet* cs = [NSMutableCharacterSet alphanumericCharacterSet];
        [cs addCharactersInString:@"-_"];
        characterSet = [cs copy];
    }
    return characterSet;
}

+(NSCharacterSet*)validKeyPathSymbolChararactersSet;
{
	static NSCharacterSet* characterSet = nil;
    if (characterSet == nil) {
    	NSMutableCharacterSet* cs = [NSMutableCharacterSet alphanumericCharacterSet];
        [cs addCharactersInString:@"_."];
        characterSet = [cs copy];
    }
    return characterSet;
}

+(NSCharacterSet*)validXMLSymbolChararactersSet;
{
	static NSCharacterSet* characterSet = nil;
    if (characterSet == nil) {
    	NSMutableCharacterSet* cs = [NSMutableCharacterSet alphanumericCharacterSet];
        [cs addCharactersInString:@"-_:"];
        characterSet = [cs copy];
    }
    return characterSet;
}

@end
