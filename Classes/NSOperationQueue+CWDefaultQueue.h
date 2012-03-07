//
//  NSOperationQueue+CWDefaultQueue.h
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
 * @abstract Category on NSOperationQueue to add support for a default queue.
 */
@interface NSOperationQueue (CWDefaultQueue)

/*!
 * Returns the shared NSOperationQueue instance. A shared instance with max
 * concurent operations set to CW_DEFAULT_OPERATION_COUNT will be created if no
 * shared instance has previously been set, or created.
 *
 * @result a shared NSOperationQueue instance.
 */
+(NSOperationQueue*)defaultQueue;

/*!
 * Set the shared NSOperationQueue instance.
 * 
 * @param operationQueue the new shared NSOperationQueue instance.
 */
+(void)setDefaultQueue:(NSOperationQueue*)operationQueue;


/**
 * Cancel all queued and executing operations of a class.
 *
 * @param aClass the operation subclass to cancel.
 */
-(void)cancelOperationsOfClass:(Class)aClass;

@end

/*!
 * @abstract Category on NSObject to add support for the default NSoperationQueue
 */
@interface NSObject (CWDefaultQueue)

/*!
 * Invokes a method of the receiver on a new background queue.
 *
 * @param aSelector A selector that identifies the method to invoke. 
 *									The method should not have a significant return value and 
 *									should take a single argument of type id, or no arguments.
 * @param arg The argument to pass to the method when it is invoked. 
 *            Pass nil if the method does not take an argument.
 * @result an autoreleased NSInvocationOperation instance.
 *			   Can be used to setup dependencies.
 */
-(NSInvocationOperation*)performSelectorInDefaultQueue:(SEL)aSelector withObject:(id)arg;

/*!
 * Invokes a method of the receiver on a specific queue.
 *
 * @param aSelector A selector that identifies the method to invoke. 
 *									The method should not have a significant return value and 
 *									should take a single argument of type id, or no arguments.
 * @param queue The queue to invoke on.
 * @param arg The argument to pass to the method when it is invoked. 
 *            Pass nil if the method does not take an argument.
 * @result an autoreleased NSInvocationOperation instance.
 *			   Can be used to setup dependencies.
 */
-(NSInvocationOperation*)performSelector:(SEL)aSelector onQueue:(NSOperationQueue*)queue withObject:(id)arg;

/*!
 * Invokes a method of the receiver on a new background queue.
 *
 * @param aSelector A selector that identifies the method to invoke. 
 *									The method should not have a significant return value and 
 *									should take a single argument of type id, or no arguments.
 * @param arg The argument to pass to the method when it is invoked. 
 *            Pass nil if the method does not take an argument.
 * @param dependencies an array of operations that must complete before
 *                     this operation can execute.
 * @param priority Sets the priority of the operation.
 * @result an autoreleased NSInvocationOperation instance.
 *			   Can be used to setup dependencies.
 */
-(NSInvocationOperation*)performSelector:(SEL)aSelector onQueue:(NSOperationQueue*)queue withObject:(id)arg dependencies:(NSArray*)dependencies priority:(NSOperationQueuePriority)priority waitUntilDone:(BOOL)wait;

@end
