//
//  NSObject+CWProxy.m
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

#import "NSObject+CWInvocationProxy.h"

#import "NSOperationQueue+CWDefaultQueue.h"

typedef NS_ENUM(NSInteger, CWInvocationProxyType) {
	CWInvocationProxyTypeBackgound,
	CWInvocationProxyTypeThread,
	CWInvocationProxyTypeQueue,
} ;

@interface CWInvocationProxy : NSObject {
@private
    id _target;
    CWInvocationProxyType _type;
    NSThread* _thread;
    NSOperationQueue* _queue;
    BOOL _wait;
    NSTimeInterval _delay;
}

+(id)backgroundProxyForTarget:(id)target;
+(id)threadProxyForTarget:(id)target onThread:(NSThread*)thread;
+(id)queueProxyForTarget:(id)target onQueue:(NSOperationQueue*)queue;

/*!
 * @abstract Hook for preparing/replacing objects before transfereing to new context.
 */
-(void)prepareInvocationForForwardingToNewContext:(NSInvocation*)invocation;

/*!
 * @abstract Hook for preparing/replacing objects before invoking in new context.
 */
-(void)prepareInvocationForInvokingInNewContext:(NSInvocation*)invocation;


@end



@implementation NSObject (CWInvocationProxy)

-(id)mainThreadProxy;
{
    return [self threadProxy:[NSThread mainThread]];
}

-(id)backgroundProxy;
{
    return [CWInvocationProxy backgroundProxyForTarget:self];
}

-(id)threadProxy:(NSThread*)thread;
{
	return [CWInvocationProxy threadProxyForTarget:self onThread:thread];
}

-(id)defaultQueueProxy;
{
    return [self queueProxy:[NSOperationQueue defaultQueue]];
}

-(id)queueProxy:(NSOperationQueue*)queue;
{
    return [CWInvocationProxy queueProxyForTarget:self onQueue:queue];
}

-(id)waitUntilDone;
{
    return self;
}

-(id)afterDelay:(NSTimeInterval)delay;
{
	CWInvocationProxy* proxy = [CWInvocationProxy threadProxyForTarget:self onThread:[NSThread currentThread]];
    return [proxy afterDelay:delay];
}

@end


@implementation CWInvocationProxy

+(id)backgroundProxyForTarget:(id)target;
{
    CWInvocationProxy* proxy = [[[self alloc] init] autorelease];
    proxy->_target = [target retain];
    proxy->_type = CWInvocationProxyTypeBackgound;
    return proxy;
}

+(id)threadProxyForTarget:(id)target onThread:(NSThread*)thread;
{
    CWInvocationProxy* proxy = [[[self alloc] init] autorelease];
    proxy->_target = [target retain];
    proxy->_type = CWInvocationProxyTypeThread;
    proxy->_thread = [thread retain];
    return proxy;
}

+(id)queueProxyForTarget:(id)target onQueue:(NSOperationQueue*)queue;
{
    CWInvocationProxy* proxy = [[[self alloc] init] autorelease];
    proxy->_target = [target retain];
    proxy->_type = CWInvocationProxyTypeQueue;
    proxy->_queue = [queue retain];
    return proxy;
}

-(instancetype)init;
{
    self = [super init];
    if (self) {
    	_delay = -1;
    }
    return self;
}

-(void)dealloc;
{
    [_target release];
    [_thread release];
    [_queue release];
    [super dealloc];
}

-(BOOL)respondsToSelector:(SEL)aSelector;
{
    return [super respondsToSelector:aSelector] || [_target respondsToSelector:aSelector];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector;
{
	if ([_target respondsToSelector:aSelector]) {
	    return [_target methodSignatureForSelector:aSelector];
    } else {
    	return [super methodSignatureForSelector:aSelector];
    }
}

-(void)prepareInvocationForForwardingToNewContext:(NSInvocation*)invocation;
{
}

-(void)prepareInvocationForInvokingInNewContext:(NSInvocation*)invocation;
{
}

-(void)performInvocation:(NSInvocation*)invocation;
{
    [self prepareInvocationForInvokingInNewContext:invocation];
    [invocation invoke];
}

-(void)forwardInvocation:(NSInvocation *)invocation;
{
    if (_delay >= 0) {
    	[self performSelector:@selector(forwardInvocation:) 
                   withObject:invocation
                   afterDelay:_delay];
        _delay = -1;
        return;
    }
    [invocation setTarget:_target];
    [self prepareInvocationForForwardingToNewContext:invocation];
	switch (_type) {
        case CWInvocationProxyTypeBackgound:
            [self performSelectorInBackground:@selector(performInvocation:)
                                   withObject:invocation];
            break;
        case CWInvocationProxyTypeThread:
            if ([NSThread currentThread] == _thread) {
                [self performInvocation:invocation];
            } else {
                [self performSelector:@selector(performInvocation:)
                             onThread:_thread
                           withObject:invocation
                        waitUntilDone:_wait];
            }
            break;
        case CWInvocationProxyTypeQueue: {
            [self performSelector:@selector(performInvocation:)
                          onQueue:_queue
                       withObject:invocation
                     dependencies:nil
                         priority:NSOperationQueuePriorityNormal
                    waitUntilDone:_wait];
            break;
        }
    }
}

-(id)waitUntilDone;
{
    _wait = YES;
    return self;
}

-(id)afterDelay:(NSTimeInterval)delay;
{
    _delay = delay;
    return self;
}

@end


