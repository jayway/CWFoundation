//
//  NSURLSystem+CWAdditions.m
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

#import "NSURLLoadingSystem+CWAdditions.h"

@implementation NSURLConnection (CWURLLoadingSystemAdditions)

+(NSString*)applicationHTTPUserAgent;
{
	static NSString* userAgent = nil;
    @synchronized (self) {
        if (userAgent == nil) {
            NSString* appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
            NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
            id device = [NSClassFromString(@"UIDevice") performSelector:@selector(currentDevice)];
            NSString* deviceName = (id)[device performSelector:@selector(model)];
            NSString* osName = (id)[device performSelector:@selector(systemName)];
            NSString* osVersion = (id)[device performSelector:@selector(systemVersion)];
            userAgent = [[NSString alloc] initWithFormat:@"%@/%@ (%@; %@ %@)", 
                         appName, appVersion, deviceName, osName, osVersion];
        }
    }
    return userAgent;
}

static NSDictionary* defaultHTTPHeaderFields = nil;

+(NSDictionary*)defaultHTTPHeaderFields;
{
    @synchronized(self) {
        if (defaultHTTPHeaderFields == nil) {
            defaultHTTPHeaderFields = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [self applicationHTTPUserAgent], @"User-Agent", nil];
        }
    }
	return defaultHTTPHeaderFields;
}

-(void)setDefaultHTTPHeaderFields:(NSDictionary*)fields;
{
    @synchronized (self) {
        [defaultHTTPHeaderFields release];
        defaultHTTPHeaderFields = [fields copy];
    }
}

@end


@implementation NSURLRequest (CWURLLoadingSystemAdditions)

+(id)requestWithURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields;
{
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [fields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[request setValue:obj forHTTPHeaderField:key];
    }];
    return [[request copy] autorelease];
}

@end


@implementation NSData (CWURLLoadingSystemAdditions)

+(id)dataWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields;
{
	return [self dataWithContentsOfURL:url 
                      HTTPHeaderFields:fields 
                               options:0
                                 error:NULL];
}

+(id)dataWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields options:(NSDataReadingOptions)mask error:(NSError **)error;
{
	return [[[self alloc] initWithContentsOfURL:url 
                               HTTPHeaderFields:fields 
                                        options:0 
                                          error:error] autorelease];
}

-(id)initWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields;
{
	return [self initWithContentsOfURL:url 
                      HTTPHeaderFields:fields 
                               options:0 
                                 error:NULL];
}

-(id)initWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields options:(NSDataReadingOptions)mask error:(NSError **)error;
{
    NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url
                                                                       HTTPHeaderFields:fields]
                                         returningResponse:NULL 
                                                     error:error];
    if (data) {
	    self = [self initWithData:data];
    } else {
        [self release];
        self = nil;
    }
    return self;
}

@end


@implementation NSString (CWURLLoadingSystemAdditions)

+(id)stringWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields encoding:(NSStringEncoding)enc error:(NSError **)error;
{
	return [[[self alloc] initWithContentsOfURL:url 
                               HTTPHeaderFields:fields 
                                       encoding:enc 
                                          error:error] autorelease];
}

+(id)stringWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields usedEncoding:(NSStringEncoding*)enc error:(NSError **)error;
{
	return [[[self alloc] initWithContentsOfURL:url
                               HTTPHeaderFields:fields
                                   usedEncoding:enc
                                          error:error] autorelease];
}

-(id)initWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields encoding:(NSStringEncoding)enc error:(NSError **)error;
{
    NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url
                                                                       HTTPHeaderFields:fields]
                                         returningResponse:NULL 
                                                     error:error];
    if (data) {
        self = [self initWithData:data 
                         encoding:enc];
    } else {
        [self release];
        self = nil;
    }
    return self;
}

-(id)initWithContentsOfURL:(NSURL*)url HTTPHeaderFields:(NSDictionary*)fields usedEncoding:(NSStringEncoding*)enc error:(NSError **)error;
{
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url
                                                                       HTTPHeaderFields:fields]
                                         returningResponse:&response 
                                                     error:error];
    if (data) {
        CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]);
        if (cfEncoding == kCFStringEncodingInvalidId) {
        	cfEncoding = kCFStringEncodingUTF8;
        }
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
        self = [self initWithData:data 
                         encoding:encoding];
        if (self && enc) {
        	*enc = encoding;
        }
    } else {
        [self release];
        self = nil;
    }
    return self;
}

@end
