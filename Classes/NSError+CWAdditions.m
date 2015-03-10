//
//  NSError+CWAdditions.m
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

#import "NSError+CWAdditions.h"

NSString* const CWFoundationAdditionsErrorDomain = @"CWFoundationAdditionsErrorDomain";
NSString* const CWApplicationErrorDomain = @"CWApplicationErrorDomain";

@implementation NSError (CWErrorAdditions)

-(instancetype)init;
{
	return [self initWithDomain:CWFoundationAdditionsErrorDomain code:0 userInfo:nil];
}

-(instancetype)initWithError:(NSError*)error;
{
    return [self initWithDomain:[error domain] code:[error code] userInfo:[error userInfo]];
}

+(instancetype)errorWithError:(NSError*)error;
{
	return [[[self alloc] initWithError:error] autorelease];
}

+(instancetype)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason;
{
	return [self errorWithDomain:domainOrNil
                            code:code
            localizedDescription:description
                 localizedReason:reason
     localizedRecoverySuggestion:nil
               recoveryAttempter:nil
        localizedRecoveryOptions:nil];    
}

+(instancetype)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason
localizedRecoverySuggestion:(NSString*)suggestionOrNil
         recoveryAttempter:(id<CWErrorRecoveryAttempting>)recoveryAttempterOrNil
  localizedRecoveryOptions:(NSArray*)recoveryOptionsOrNil;
{
    if (domainOrNil == nil) {
    	domainOrNil = CWApplicationErrorDomain;
    }
	NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    userInfo[NSLocalizedDescriptionKey] = description;
    userInfo[NSLocalizedFailureReasonErrorKey] = reason;
    if (suggestionOrNil) {
    	userInfo[NSLocalizedRecoverySuggestionErrorKey] = suggestionOrNil;
    }
    if (recoveryAttempterOrNil && [recoveryOptionsOrNil count] > 0) {
    	userInfo[NSRecoveryAttempterErrorKey] = recoveryAttempterOrNil;
        userInfo[NSLocalizedRecoveryOptionsErrorKey] = recoveryOptionsOrNil;
    }
    return [self errorWithDomain:domainOrNil code:code userInfo:userInfo];
}

-(NSError*)underlyingError;
{
	return [self userInfo][NSUnderlyingErrorKey];    
}

-(id)copyWithZone:(NSZone *)zone;
{
    if ([self isKindOfClass:[NSMutableError class]]) {
		return [[NSError allocWithZone:zone] initWithError:self];
    } else {
    	return [self retain];
    }
}

- (id)mutableCopyWithZone:(NSZone *)zone;
{
	return [[NSMutableError allocWithZone:zone] initWithError:self];
}

@end

@implementation NSMutableError

- (instancetype)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
{
	self = [super initWithDomain:domain code:code userInfo:dict];
    if (self) {
    	_mutableUserInfo = [[NSMutableDictionary alloc] initWithCapacity:[dict count] + 4];
        if (dict) {
        	[_mutableUserInfo addEntriesFromDictionary:dict];
        }
    }
    return self;
}

+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
{
	return [[[self alloc] initWithDomain:domain code:code userInfo:dict] autorelease];
}

-(void)dealloc;
{
	[_mutableUserInfo release];
    [super dealloc];
}

-(NSDictionary*)userInfo;
{
	if ([_mutableUserInfo count] > 0) {
    	return [NSDictionary dictionaryWithDictionary:_mutableUserInfo];
    }
    return nil;
}

-(NSMutableDictionary*)mutableUserInfo;
{
	return _mutableUserInfo;
}

- (void)setDomain:(NSString *)domain;
{
	[self setValue:[NSString stringWithString:domain]
            forKey:@"_domain"];    
}

- (void)setCode:(NSInteger)code;
{
	[self setValue:@(code) 
            forKey:@"_code"];
}

- (void)setLocalizedDescription:(NSString*)description;
{
    if (description) {
		_mutableUserInfo[NSLocalizedDescriptionKey] = [NSString stringWithString:description];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedDescriptionKey];
    }
}

- (void)setLocalizedFailureReason:(NSString*)reason;
{
    if (reason) {
		_mutableUserInfo[NSLocalizedFailureReasonErrorKey] = [NSString stringWithString:reason];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedFailureReasonErrorKey];
    }
}

- (void)setLocalizedRecoverySuggestion:(NSString*)recoverySuggestion;
{
    if (recoverySuggestion) {
		_mutableUserInfo[NSLocalizedRecoverySuggestionErrorKey] = [NSString stringWithString:recoverySuggestion];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedRecoverySuggestionErrorKey];
    }
}

- (void)setLocalizedRecoveryOptions:(NSArray*)recoveryOptions;
{
    if (recoveryOptions) {
		_mutableUserInfo[NSLocalizedRecoveryOptionsErrorKey] = [NSArray arrayWithArray:recoveryOptions];
    } else {
    	[_mutableUserInfo removeObjectForKey:NSLocalizedRecoveryOptionsErrorKey];
    }
}

- (void)setRecoveryAttempter:(id)recoveryAttempter;
{
    if (recoveryAttempter) {
		_mutableUserInfo[NSRecoveryAttempterErrorKey] = recoveryAttempter;
    } else {
    	[_mutableUserInfo removeObjectForKey:NSRecoveryAttempterErrorKey];
    }
}

- (void)setUnderlyingError:(NSError*)error;
{
	if (error) {
    	_mutableUserInfo[NSUnderlyingErrorKey] = error;
    } else {
        [_mutableUserInfo removeObjectForKey:NSUnderlyingErrorKey];
    }
}

@end

