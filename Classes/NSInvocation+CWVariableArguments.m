//
//  NSInvocation+CWVariableArguments.m
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

#import "NSInvocation+CWVariableArguments.h"
#import "NSOperationQueue+CWDefaultQueue.h"
#include <stdarg.h>
#include <objc/runtime.h>

@implementation NSInvocation (CWVariableArguments)

+(NSInvocation*)invocationForInstancesOfClass:(Class)aClass
                                 withSelector:(SEL)selector
                              retainArguments:(BOOL)retainArguments, ...;
{
	va_list arguments;
    va_start(arguments, retainArguments);
    NSInvocation* invocation = [self invocationForInstancesOfClass:aClass
                                                      withSelector:selector
                                                   retainArguments:retainArguments
                                                         arguments:arguments];
    va_end(arguments);
	return invocation;
}

+(NSInvocation*)invocationForInstancesOfClass:(Class)aClass
                                 withSelector:(SEL)selector
                              retainArguments:(BOOL)retainArguments
                                    arguments:(va_list)arguments;
{
    NSMethodSignature* signature = signature = [aClass instanceMethodSignatureForSelector:selector];
    if (aClass == Nil || selector == NULL || signature == nil) {
    	return nil;
    }
    char* args = (char*)arguments;
    NSInvocation* invocation = [self invocationWithMethodSignature:signature];
    if (retainArguments) {
        [invocation retainArguments];
    }
    [invocation setSelector:selector];
    for (int index = 2; index < [signature numberOfArguments]; index++) {
        const char *type = [signature getArgumentTypeAtIndex:index];
        NSUInteger size, align = 4;
        NSGetSizeAndAlignment(type, &size, NULL);
        NSUInteger mod = (NSUInteger)args % align;
        if (mod != 0) {
            args += (align - mod);
        }
        // float is stored as double on stack according to mach-o ABI.
        if (strcmp(type, @encode(float)) == 0) {
        	float tmp = *(double*)args;
            [invocation setArgument:&tmp atIndex:index];
            args += sizeof(double);
        } else {
	        [invocation setArgument:args atIndex:index];
    	    args += size;
        }
    }
    return invocation;
}

+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)aSelector
                     retainArguments:(BOOL)retainArguments, ...;
{
	va_list arguments;
    va_start(arguments, retainArguments);
    NSInvocation* invocation = [self invocationWithTarget:target 
                                                 selector:aSelector 
                                          retainArguments:retainArguments 
                                                arguments:arguments];
    va_end(arguments);
	return invocation;
}

+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)aSelector
                     retainArguments:(BOOL)retainArguments
                           arguments:(va_list)arguments;
{
    NSInvocation* invocation = [self invocationForInstancesOfClass:object_getClass(target)
                                                      withSelector:aSelector
                                                   retainArguments:retainArguments
                                                         arguments:arguments];
    [invocation setTarget:target];
    return invocation;
}

-(void)invokeInBackground;
{
	[self performSelectorInBackground:@selector(invoke) withObject:nil];
}

-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;
{
	[self invokeOnThread:[NSThread mainThread] waitUntilDone:wait];
}

-(void)invokeOnThread:(NSThread*)thread waitUntilDone:(BOOL)wait;
{
    if ([[NSThread currentThread] isEqual:thread]) {
    	[self invoke];
    } else {
    	[self performSelector:@selector(invoke) 
                     onThread:thread
                   withObject:nil
                waitUntilDone:wait];
    }
}

-(void)invokeOnDefaultQueueWaitUntilDone:(BOOL)wait;
{
	[self invokeOnOperationQueue:[NSOperationQueue defaultQueue] waitUntilDone:wait];
}

-(void)invokeOnOperationQueue:(NSOperationQueue*)queue waitUntilDone:(BOOL)wait;
{
	NSOperation* operation = [[NSInvocationOperation alloc] initWithInvocation:self];
    [queue addOperation:operation];
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
    [operation release];
}

-(void)invokeAfterDelay:(NSTimeInterval)delay;
{
	[self performSelector:@selector(invoke) 
               withObject:nil 
               afterDelay:delay];
}

-(void)invokeAfterDelayHelperWithDelay:(NSNumber*)delay;
{
	[self invokeAfterDelay:[delay doubleValue]];
}

-(void)invokeOnThread:(NSThread*)thread afterDelay:(NSTimeInterval)delay;
{
	[self performSelector:@selector(invokeAfterDelayHelperWithDelay:)
                 onThread:thread
               withObject:@(delay)
            waitUntilDone:NO];		
}

-(void)invokeWithAllTargets:(NSArray*)targets;
{
	for (id target in targets) {
    	[self invokeWithTarget:target];
    }
}

@end

