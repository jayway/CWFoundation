/*
 
 File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 
 Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/
//
//  CWNetworkMonitor.m
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

#import "CWNetworkMonitor.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString* const CWNetWorkStatusDidChangeNotification = @"CWNetWorkCheckerNetworkStatusDidChangeNotification";

static const SCNetworkReachabilityFlags kConnectionDown =  kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection;


@implementation CWNetworkMonitor

@synthesize hostName = _hostName;

static CWNetworkMonitor* _defaultMonitor = nil;

-(instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;
{
	self = [super init];
    if (self) {
    	_reachabilityRef = CFRetain(ref);
        _lastKnownStatus = CWNetworkStatusUnknown;
    }
    return self;
}

-(void)dealloc;
{
    [self stopMonitoringNetworkStatus];
	[_hostName release];
    [super dealloc];
}

+(CWNetworkMonitor*)defaultMonitor;
{
    @synchronized(self) {
        if (_defaultMonitor == nil) {
            [self setDefaultMonitor:[self monitorForInternetConnection]];
        }
    }
    return _defaultMonitor;
}

+(void)setDefaultMonitor:(CWNetworkMonitor*)monitor;
{
	@synchronized(self) {
    	[_defaultMonitor autorelease];
        _defaultMonitor = [monitor retain];
    }
}

+(CWNetworkMonitor*)monitorForInternetConnection;
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	CWNetworkMonitor* monitor = [self monitorWithAddress:&zeroAddress];
    	
	return monitor;
}

+(CWNetworkMonitor*)monitorForLocalWiFi;
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    
	CWNetworkMonitor* monitor = [self monitorWithAddress:&localWifiAddress];
    monitor->_isLocalWiFi = YES;

	return monitor;
}

+(CWNetworkMonitor*)monitorWithHostName:(NSString*)hostName;
{
	SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);	
	if (ref) {
		CWNetworkMonitor* monitor = [[[self alloc] initWithReachabilityRef:ref] autorelease];
        CFRelease(ref);
        monitor->_hostName = [hostName copy];
		return monitor;
	}
	return nil;
}

+(NSString*)hostForAddress:(in_addr_t)addr;
{
	addr = ntohl(addr);	
	return [NSString stringWithFormat: @"%d.%d.%d.%d", 
			(addr >> 24) & 0xff, 
			(addr >> 16) & 0xff, 
			(addr >> 8)  & 0xff, 
            addr         & 0xff];
	
}

+(CWNetworkMonitor*)monitorWithAddress:(const struct sockaddr_in*)hostAddress;
{
	SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
	if (ref) {
		CWNetworkMonitor* monitor = [[[self alloc] initWithReachabilityRef:ref] autorelease];
		CFRelease(ref);
        monitor->_hostName = [[self hostForAddress:hostAddress->sin_addr.s_addr] copy];
		return monitor;
	}	
	return nil;
}

-(void)updateNetworkStatusWithFLags:(SCNetworkReachabilityFlags)flags;
{
	_lastKnownStatus = CWNetworkStatusNotAvailable;
	
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        
        if (_isLocalWiFi) {
			_lastKnownStatus = (flags & kSCNetworkReachabilityFlagsIsDirect) ? CWNetworkStatusAvailableViaWiFi : CWNetworkStatusNotAvailable;
			return;
		}
        
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            _lastKnownStatus = CWNetworkStatusAvailableViaWWAN;
            return;
        }
        
        flags &= ~kSCNetworkReachabilityFlagsReachable;
        flags &= ~kSCNetworkReachabilityFlagsIsDirect;
        flags &= ~kSCNetworkReachabilityFlagsIsLocalAddress; // kInternetConnection is local.
        if (flags == kConnectionDown) {
            _lastKnownStatus = CWNetworkStatusNotAvailable;
            return; 
        }
        
        if (flags & kSCNetworkReachabilityFlagsTransientConnection)  {
            _lastKnownStatus = CWNetworkStatusAvailableViaWiFi;
            return; 
        }
        if (flags == 0) {
            _lastKnownStatus = CWNetworkStatusAvailableViaWiFi;
            return; 
        }
        if (flags & kSCNetworkReachabilityFlagsConnectionRequired) { 
            _lastKnownStatus = CWNetworkStatusAvailableViaWiFi;
            return;
        }
        
        _lastKnownStatus = CWNetworkStatusNotAvailable;
    }
}

-(CWNetworkStatus)networkStatus;
{
    @synchronized (self) {
        if (!_isMonitoring) {
            return CWNetworkStatusUnknown;
        }
        if (_lastKnownStatus == CWNetworkStatusUnknown) {
            if ([NSThread isMainThread]) {
                [self performSelectorInBackground:_cmd withObject:nil];
            } else {
                NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
                static BOOL isChecking = NO;
                if (!isChecking) {
                    isChecking = YES;
                    SCNetworkReachabilityFlags flags = 0;
                    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
                        [self updateNetworkStatusWithFLags:flags];
                        NSNotification* notification = [NSNotification notificationWithName:CWNetWorkStatusDidChangeNotification
                                                                                     object:self];
                        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
                                                                               withObject:notification
                                                                            waitUntilDone:NO];
                    }
                }
                [pool release];
            }
        }
    }
	return _lastKnownStatus;        
}

-(BOOL)isAvailable;
{
	return ([self networkStatus] > CWNetworkStatusNotAvailable);    
}

-(BOOL)isMonitoringNetworkStatus;
{
	return _isMonitoring;    
}

static void CWReachabilityCallback(SCNetworkReachabilityRef target, 
                                   SCNetworkReachabilityFlags flags, 
                                   void* info) {    
#pragma unused (target, flags)
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	
	CWNetworkMonitor* monitor = (CWNetworkMonitor*)info;
    [monitor updateNetworkStatusWithFLags:flags];
	[[NSNotificationCenter defaultCenter] postNotificationName:CWNetWorkStatusDidChangeNotification
														object:monitor];
	
	[pool release];    
}

-(BOOL)startMonitoringNetworkStatus;
{
    if ([self isMonitoringNetworkStatus]) {
    	[self stopMonitoringNetworkStatus];
    }
    _isMonitoring = YES;
    SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
    BOOL success = NO;
	if (SCNetworkReachabilitySetCallback(_reachabilityRef, CWReachabilityCallback, &context)) {
		success = SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, 
                                                           CFRunLoopGetCurrent(), 
                                                           kCFRunLoopDefaultMode);
	}
	[self networkStatus];
	return success;
}

-(void)stopMonitoringNetworkStatus;
{
	if ([self isMonitoringNetworkStatus]) {
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef,
                                                   CFRunLoopGetCurrent(), 
                                                   kCFRunLoopDefaultMode);
		_isMonitoring = NO;
        _lastKnownStatus = CWNetworkStatusUnknown;
    }
}

@end
