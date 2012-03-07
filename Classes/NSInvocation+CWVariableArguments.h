//
//  NSInvocation+CWVariableArguments.h
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
 * @abstract Category on NSInvocation adding convinience methods for creating invocations and invoking on different targets.
 *
 * @deprecated This categoryy on NSInvocation is superseeded by NSObject<CWProxy>.
 */
@interface NSInvocation (CWVariableArguments)

/*!
 * @abstract Create an NSInvocation instance for a given NSMethodSignature, and initialize it
 *           using a variable list of arguments.
 *
 * @discussion No target is set on the returned invication.
 *             Arguments are not retained by NSInvocation by default for
 *			   performance. Always retain arguments when passing objects across
 *             thread boundries.
 *
 * @param retainArguments YES if object arguments should be retained.
 * @param ... a list of arguments to send to the method when invoking.
 * @result a prepared invocation object.
 */
+(NSInvocation*)invocationForInstancesOfClass:(Class)aClass
                                 withSelector:(SEL)selector
                              retainArguments:(BOOL)retainArguments, ...;

/*!
 * @abstract Create an NSInvocation instance for a given NSMethodSignature, and initialize it
 *           using a variable list of arguments.
 *
 * @discussion No target is set on the returned invication.
 *             Arguments are not retained by NSInvocation by default for
 *			   performance. Always retain arguments when passing objects across
 *             thread boundries.
 *
 * @param retainArguments YES if object arguments should be retained.
 * @param arguments a variable arguments list with arguments to send to the method when invoking.
 * @result a prepared invocation object.
 */
+(NSInvocation*)invocationForInstancesOfClass:(Class)aClass
                                 withSelector:(SEL)selector
                              retainArguments:(BOOL)retainArguments
                                    arguments:(va_list)arguments;

/*!
 * @abstract Create an NSInvication instance for a given target, selector, and a
 *					 variable list of arguments.
 *
 * @discussion Arguments are not retained by NSInvocation by default for
 *			   performance. Always retain arguments when passing objects across
 *             thread boundries.
 *
 * @param target target of invocation.
 * @param selector selector of method to invoke on target.
 * @param retainArguments YES if object arguments should be retained.
 * @param ... a list of arguments to send to the method when invoking.
 * @result a prepared invocation object.
 */
+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)selector
                     retainArguments:(BOOL)retainArguments, ...;

/*!
 * @abstract Create an NSInvication instance for a given target, selector, and a
 *					 variable list of arguments.
 *
 * @discussion Arguments are not retained by NSInvocation by default for
 *			   performance. Always retain arguments when passing objects across
 *             thread boundries.
 *
 * @param target target of invocation.
 * @param selector selector of method to invoke on target.
 * @param retainArguments YES if object arguments should be retained.
 * @param arguments a variable arguments list with arguments to send to the method when invoking.
 * @result a prepared invocation object.
 */
+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)selector
                     retainArguments:(BOOL)retainArguments
                           arguments:(va_list)arguments;

/*!
 * @abstract Perform invoke on a new bakcground thread.
 *
 * @discussion You should NOT read the return value, since there is no way to
 * 						 know when the invokation has finnished.
 */
-(void)invokeInBackground;

/*!
 * @abstract Perform invoke on the main thread, optionally wait until done.
 *
 * @abstract You should only read the return value if you have waited until the
 *           invocation is done.
 */
-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;

/*!
 * @abstract Perform invoke on the specified thread, optionally waut until done.
 *
 * @abstract You should only read the return value if you have waited until the
 *           invocation is done.
 */
-(void)invokeOnThread:(NSThread*)thread waitUntilDone:(BOOL)wait;

/*!
 * @abstract Perform invoke on the shared operation queue, optionally wait until done.
 *
 * @abstract You should only read the return value if you have waited until the
 *           invocation is done.
 */
-(void)invokeOnDefaultQueueWaitUntilDone:(BOOL)wait;


/*!
 * @abstract Perform invoke on the specified operation queue, optionally wait until done.
 *
 * @abstract You should only read the return value if you have waited until the
 *           invocation is done.
 */
-(void)invokeOnOperationQueue:(NSOperationQueue*)queue waitUntilDone:(BOOL)wait;

/*!
 * @abstract Perform invoke on current thread after a delay.
 *
 * @param delay delay until performing selector.
 */
-(void)invokeAfterDelay:(NSTimeInterval)delay;


/*!
 * @abstract Perform invoke on any thhread after a delay.
 *
 * @param delay delay until performing selector.
 */
-(void)invokeOnThread:(NSThread*)thread afterDelay:(NSTimeInterval)delay;

/*!
 * @abstract Perform invokeWithTarget: using all objects in array.
 *
 * @param targets List of all targets to invoke with.
 */
-(void)invokeWithAllTargets:(NSArray*)targets;

@end
