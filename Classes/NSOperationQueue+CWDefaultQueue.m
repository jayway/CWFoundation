//
//  NSOperationQueue+CWDefaultQueue.m
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

#import "NSOperationQueue+CWDefaultQueue.h"


@implementation NSOperationQueue (CWDefaultQueue)

static NSOperationQueue* cw_defaultQueue = nil;

+(NSOperationQueue*)defaultQueue;
{
	if (cw_defaultQueue == nil) {
        cw_defaultQueue = [[NSOperationQueue alloc] init];
    }
    return cw_defaultQueue;
}

+(void)setDefaultQueue:(NSOperationQueue*)operationQueue;
{
	if (operationQueue != cw_defaultQueue) {
        cw_defaultQueue = operationQueue;
    }
}

-(void)cancelOperationsOfClass:(Class)aClass;
{
	for (NSOperation* operation in [self operations]) {
    	if ([operation isKindOfClass:aClass]) {
        	[operation cancel];
        }
    }
}

@end


@implementation NSObject (CWDefaultQueue)

-(NSInvocationOperation*)performSelectorInDefaultQueue:(SEL)aSelector withObject:(id)arg;
{
    return [self performSelector:aSelector
                         onQueue:[NSOperationQueue defaultQueue]
                      withObject:arg];
}

-(NSInvocationOperation*)performSelector:(SEL)aSelector onQueue:(NSOperationQueue*)queue withObject:(id)arg;
{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:aSelector object:arg];
    [queue addOperation:operation];
	return operation;  
}

-(NSInvocationOperation*)performSelector:(SEL)aSelector onQueue:(NSOperationQueue*)queue withObject:(id)arg dependencies:(NSArray*)dependencies priority:(NSOperationQueuePriority)priority waitUntilDone:(BOOL)wait;
{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:aSelector object:arg];
    [operation setQueuePriority:priority];
    for (NSOperation* dependency in dependencies) {
        [operation addDependency:dependency]; 
    }
    [[NSOperationQueue defaultQueue] addOperation:operation];
    if (wait) {
        if ([operation respondsToSelector:@selector(waitUntilFinished)]) {
		    [operation performSelector:@selector(waitUntilFinished)];
        } else {
			while ([[queue operations] containsObject:operation]) {
            	[[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes
                                         beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
            }
        }
    }
	return operation;  
}

@end
