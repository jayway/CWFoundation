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
//  CWNetworkMonitor.h
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
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


/*!
 * @abstract Sent when network status is first known and on any subsequent changes.
 * @discussion The object for this notification is the originating CWNetworkMonitor instance.
 */
extern NSString* const CWNetWorkStatusDidChangeNotification;


typedef enum {
	CWNetworkStatusUnknown = -1,
    CWNetworkStatusNotAvailable = 0,
    CWNetworkStatusAvailableViaWWAN = 1,
    CWNetworkStatusAvailableViaWiFi = 2
} CWNetworkStatus;


/*!
 * @abstract Utility class for monitoring the availability of the network.
 */
@interface CWNetworkMonitor : NSObject {
@private
	NSString* _hostName;
	SCNetworkReachabilityRef _reachabilityRef;
    CWNetworkStatus _lastKnownStatus;
    BOOL _isMonitoring;
    BOOL _isLocalWiFi;
}

/*!
 * @abstract get the receivers monitored host name.
 * @discussion Yield an IP address if not monitoring a specific host by name.
 */
@property(nonatomic, readonly, copy) NSString* hostName;

/*!
 * @abstract Get the default CWNetworkMonitor instance.
 * @discussion Lazily create a monitor for internet connection if not yet set.
 */
+(CWNetworkMonitor*)defaultMonitor;

/*!
 * @abstract Set or replace the default CWNetWorkMonitor instance.
 */
+(void)setDefaultMonitor:(CWNetworkMonitor*)monitor;

/*!
 * @abstract Get a new monitor for internet connection.
 * @discussion Use for general internet connectivity test.
 */
+(CWNetworkMonitor*)monitorForInternetConnection;

/*!
 * @abstract Get a new monitor for local WiFi connection.
 */
+(CWNetworkMonitor*)monitorForLocalWiFi;

/*!
 * @abstract Get a new monitor for specific host by name.
 * @dicsussion For example @"service.jayway.com" or "google.com".
 */
+(CWNetworkMonitor*)monitorWithHostName:(NSString*)hostName;

/*!
 * @abstract Get a new monitor for specific host by address.
 */
+(CWNetworkMonitor*)monitorWithAddress:(const struct sockaddr_in*)hostAddress;

/*!
 * @abstract Get the current network status.
 * @discussion Non blocking. Will always yield CWNetworkStatusUnknown if the 
 *             receiver is not currently monitoring.
 */
-(CWNetworkStatus)networkStatus;

/*!
 * @abstract Query if any kind of network is available.
 * @discussion Non blocking. Will always yield NO if the receiver is not
 *             currently monitoring.
 */
-(BOOL)isAvailable;

/*!
 * @abstract Query if the receiver is currently monitoring.
 */
-(BOOL)isMonitoringNetworkStatus;

/*!
 * @abstract Start monitoring network status using the receiver.
 * @discussion The receiver will post a CWNetWorkStatusDidChangeNotification
 *             notification at the earliest possible moment wit the current status,
 *             and will them continue to post this notification for any changes to
 *             the network status.
 */
-(BOOL)startMonitoringNetworkStatus;

/*!
 * @abstract Stop monitoring network status using the receiver.
 */
-(void)stopMonitoringNetworkStatus;

@end
