//
//  NSObject+CWAssociatedObject.h
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
#import <objc/runtime.h>

/*
 * Only bother to add suport for legacy associated objects if min required 
 * target is less than Mac OS X 10.6 or iPhone OS 3.1. 
 */
#ifndef CW_SUPPORT_LEGACY_ASSOCIATED_OBJECTS
	#if TARGET_OS_IPHONE
		#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_1
			#define CW_SUPPORT_LEGACY_ASSOCIATED_OBJECTS 1
		#else
			#define CW_SUPPORT_LEGACY_ASSOCIATED_OBJECTS 0
		#endif
	#else
		#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_6
			#define CW_SUPPORT_LEGACY_ASSOCIATED_OBJECTS 1
		#else
			#define CW_SUPPORT_LEGACY_ASSOCIATED_OBJECTS 0
		#endif
	#endif
#endif

/*
 * Only intended to force legacy support for unit tests.
 */
#ifndef CW_FORCE_LEGACY_ASSOCIATED_OBJECTS
	#define CW_FORCE_LEGACY_ASSOCIATED_OBJECTS 0
#endif

/*!
 * @abstract A convinience category on NSObject to work with associated objects.
 *
 * @discussion Associated objects do not require an instance variable, and are
 *             released when the object is deallocated.
 *			   Associated objects can be used to add new functionality that
 *             requires internal state in categories, for example adding a
 *             property.
 *
 *			   Associated objects where added to the Objective-C tun-time in
 *             Mac OS X 10.6 and iPhone OS 3.1 respectively. This category will
 *             use the new run-time feature if available, and fall back to a
 *             slower legacy compatible implementation when run on an older OS.
 *             The legacy implementation is fully compatible to association 
 *             policies (assign, copy, or retain) to avoid retention cycles.
 *             The legacy implementation is always atomic.
 */
@interface NSObject (CWAssociatedObject)

-(id)associatedObjectForStaticKey:(void*)key;
-(void)setAssociatedObject:(id)object forStaticKey:(void*)key;
-(void)setAssociatedObject:(id)value forStaticKey:(void *)key withAssociationPolicy:(objc_AssociationPolicy)policy; 

@end
