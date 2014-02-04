//
//  NSObject+CWProxy.h
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
 * @abstract A category on NSObject to access proxies for invoking method calls
 *           on oher threads.
 *
 * @discussion Requesting a proxy to the current thread will always yield the
 *             receiver without creating a proxy.
 */
@interface NSObject (CWInvocationProxy)

/*!
 * @abstract Proxy for invoking methods on the main thread.
 */
-(id)mainThreadProxy;

/*!
 * @abstract Proxy for invoking methods on a background thread.
 */
-(id)backgroundProxy;

/*!
 * @abstract Proxy for invoking methods on specific thread, optionaly block until done.
 */
-(id)threadProxy:(NSThread*)thread;

/*!
 * @abstract Proxy for invoking methods on default NSOperationQueue.
 */
-(id)defaultQueueProxy;

/*!
 * @abstract Proxy for invoking methods on specific NSOperationQueue.
 */
-(id)queueProxy:(NSOperationQueue*)queue;

/*!
 * @discussion Block current thread until methods has been invocated on target thread.
 * @discussion Not supported by backgroundProxy proxies.
 */
-(id)waitUntilDone;

/*!
 * @abstract Delay method invocation.
 * @discussion Overrides waitUntilDone.
 */
-(id)afterDelay:(NSTimeInterval)delay;

@end
