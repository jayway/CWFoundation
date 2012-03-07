//
//  NSInvocationVariableArgumentsTest.m
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

#import "NSInvocationVariableArgumentsTest.h"
#import "NSInvocation+CWVariableArguments.h"
#import "NSObject+CWInvocationProxy.h"

@implementation NSInvocationVariableArgumentsTest

-(void)assertBoolA:(BOOL)a b:(BOOL)b marker:(int)m;
{
	STAssertFalse(a, @"NO");
    STAssertTrue(b, @"YES");
    STAssertEquals(0x12345678, m, @"marker");
}

-(void)testMarshalBOOLArguments;
{
	[[NSInvocation invocationWithTarget:self
                               selector:@selector(assertBoolA:b:marker:)
                        retainArguments:YES, NO, YES, 0x12345678] invoke]; 
}

-(void)assertInt8:(int8_t)a int16:(int16_t)b int32:(int32_t)c int64:(int_fast64_t)d marker:(int)m;
{
	STAssertTrue(a == 11, @"11");    
	STAssertTrue(b == 222, @"222");  
	STAssertTrue(c == 3333, @"3333");    
	STAssertTrue(d == 44444L, @"44444");
    STAssertEquals(0x12345678, m, @"marker");
}

-(void)testMarshalIntegerArguments;
{
	[[NSInvocation invocationWithTarget:self
                               selector:@selector(assertInt8:int16:int32:int64:marker:)
                        retainArguments:YES, (int8_t)11, (int16_t)222, (int32_t)3333, (int64_t)44444, 0x12345678] invoke];
}

-(void)assertFloat:(float)a double:(double)b marker:(int)m;
{
	STAssertTrue(a == 1.1f, @"1.1");
    STAssertTrue(b = M_PI, @"PI");
    STAssertEquals(0x12345678, m, @"marker");
}

-(void)testMarshalRealArguments;
{
	[[NSInvocation invocationWithTarget:self
                               selector:@selector(assertFloat:double:marker:)
                        retainArguments:YES, 1.1f, M_PI, 0x12345678] invoke];
}


typedef struct {
    BOOL a;
    float b;
    double c;
    struct {
    	BOOL a;
	    __unsafe_unretained id b;
    	BOOL c;
    } d;
} CWStupid;

-(void)assertRange:(NSRange)b stupid:(CWStupid)c marker:(int)m;
{
    STAssertTrue(NSEqualRanges(b, NSMakeRange(1, 41)), @"");
    STAssertTrue(c.a == YES, @"");
    STAssertTrue(c.b == 0.75f , @"");
    STAssertTrue(c.c == 1.23456789, @"");
    STAssertTrue(c.d.a == NO, @"");
    STAssertTrue(c.d.b == self, @"");
    STAssertTrue(c.d.c == YES, @"");
    STAssertEquals(0x12345678, m, @"marker");
}

-(void)testMarshalStructArguments;
{
	CWStupid a;
	a.a = YES;
    a.b = 0.75f;
    a.c = 1.23456789;
    a.d.a = NO;
    a.d.b = self;
    a.d.c = YES;
    [[NSInvocation invocationWithTarget:self
                               selector:@selector(assertRange:stupid:marker:)
                        retainArguments:YES,
      NSMakeRange(1, 41),
      a, 0x12345678] invoke];
}

-(int)addInt:(int)a withInt:(int)b;
{
    STAssertFalse([NSThread isMainThread], @"Must be background thread");
    return a + b;
}

-(void)testInvokeOnDefaulQueue;
{
    NSInvocation* invocation = [NSInvocation invocationWithTarget:self
                                                         selector:@selector(addInt:withInt:)
                                                  retainArguments:YES, 40, 2];
    [invocation invokeOnDefaultQueueWaitUntilDone:YES];
    int result = 0;
    [invocation getReturnValue:&result];
    STAssertEquals(result, 42, @"42");
}

-(void)unlockConditionalLock:(NSConditionLock*)lock;
{
    if ([lock lockWhenCondition:0 beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]) {
		[lock unlockWithCondition:1];
    } else {
    	STFail(@"Could not aquire lock on background thread");
    }
}

-(void)testInvokeInBackground;
{
	NSConditionLock* lock = [[NSConditionLock alloc] initWithCondition:0];
    [[NSInvocation invocationWithTarget:self
                               selector:@selector(unlockConditionalLock:)
                        retainArguments:YES, lock] invokeInBackground];
    if (![lock lockWhenCondition:1
                      beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]) {
    	STFail(@"Could not aquire lock on main thread");
    }
}

-(void)testCurrentThreadProxy;
{
    NSConditionLock* lock = [[NSConditionLock alloc] initWithCondition:0];
	[[self threadProxy:[NSThread currentThread]] unlockConditionalLock:lock];
    if (![lock lockWhenCondition:1
                      beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]) {
    	STFail(@"Could not aquire lock on main thread");
    }    
}

-(void)testBackgroundProxy;
{
    NSLog(@"testBackgroundProxy called");
    NSConditionLock* lock = [[NSConditionLock alloc] initWithCondition:0];
	[[self backgroundProxy] unlockConditionalLock:lock];
    if (![lock lockWhenCondition:1
                      beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]) {
    	STFail(@"Could not aquire lock on main thread");
    }    
}

-(void)testQueueProxy;
{
    NSConditionLock* lock = [[NSConditionLock alloc] initWithCondition:0];
	[[self defaultQueueProxy] unlockConditionalLock:lock];
    if (![lock lockWhenCondition:1
                      beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]) {
    	STFail(@"Could not aquire lock on main thread");
    }
}

@end
