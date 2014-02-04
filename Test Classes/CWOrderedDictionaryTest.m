//
//  CWOrderedDictionaryTest.m
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

#import "CWOrderedDictionaryTest.h"


@implementation CWOrderedDictionaryTest

-(void)setUp;
{
	keys = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", nil];
    objects = [[NSArray alloc] initWithObjects:@"D", @"E", @"F", nil];
    orderedDictionary = [[CWOrderedDictionary alloc] initWithObjects:objects forKeys:keys];
}

-(void)tearDown;
{
	orderedDictionary = nil;
    objects = nil;
    keys = nil;
}

-(void)testAllInitializersYieldSameResult;
{
    CWOrderedDictionary* dict = [[CWOrderedDictionary alloc] initWithDictionary:orderedDictionary];
    STAssertEqualObjects(orderedDictionary,
                         dict,
                         @"initWithDictionary: failed");
	dict = [[CWOrderedDictionary alloc] initWithObjects:(id[]){@"D", @"E", @"F", nil} 
                                                 forKeys:(id[]){@"A", @"B", @"C", nil} 
                                                   count:3];
    STAssertEqualObjects(orderedDictionary,
                         dict,
                         @"initWithObjects:forKeys:count: failed");
    dict = [[CWOrderedDictionary alloc] initWithObjectsAndKeys:@"D", @"A", @"E", @"B", @"F", @"C", nil];
    STAssertEqualObjects(orderedDictionary,
                         dict,
                         @"initWithObjectsAndKeys: failed");
}


-(void)testKeysAndObjectsAreOrderedAfterInitialization;
{
	STAssertEqualObjects(keys,
                         [orderedDictionary allKeys],
                         @"keys not properly ordered");
	STAssertEqualObjects(objects,
                         [orderedDictionary allValues],
                         @"objects not properly ordered");
}

-(void)testInsertsWithSetObject;
{
	CWOrderedDictionary* dict = [[CWOrderedDictionary alloc] initWithCapacity:3];
    [dict setObject:@"D" forKey:@"A"];
    [dict setObject:@"E" forKey:@"B"];
    [dict setObject:@"F" forKey:@"C"];
    STAssertEqualObjects(orderedDictionary,
                         dict,
                         @"setObject:forKey: failed");
}

-(void)testInsertsWithInsertAtIndex;
{
	CWOrderedDictionary* dict = [[CWOrderedDictionary alloc] initWithCapacity:3];
    [dict insertObject:@"E" forKey:@"B" atIndex:0];
    [dict insertObject:@"F" forKey:@"C" atIndex:1];
    [dict insertObject:@"D" forKey:@"A" atIndex:0];
    STAssertEqualObjects(orderedDictionary,
                         dict,
                         @"insertObject:forKey:atIndex: failed");
}


-(void)testKeyAndObjectAtIndex;
{
	STAssertEqualObjects(@"A", [orderedDictionary keyAtIndex:0], @"keyAtIndex:0 failed");    
	STAssertEqualObjects(@"B", [orderedDictionary keyAtIndex:1], @"keyAtIndex:1 failed");    
	STAssertEqualObjects(@"C", [orderedDictionary keyAtIndex:2], @"keyAtIndex:2 failed");
    STAssertEqualObjects(@"D", [orderedDictionary objectAtIndex:0], @"objectAtIndex:0 failed");
    STAssertEqualObjects(@"E", [orderedDictionary objectAtIndex:1], @"objectAtIndex:1 failed");
    STAssertEqualObjects(@"F", [orderedDictionary objectAtIndex:2], @"objectAtIndex:2 failed");
}

-(void)testObjectAtIndexAndForKey;
{
	STAssertEqualObjects(@"D", [orderedDictionary objectForKey:@"A"], @"objectForKey: failed");
	STAssertEqualObjects(@"E", [orderedDictionary objectForKey:@"B"], @"objectForKey: failed");
	STAssertEqualObjects(@"F", [orderedDictionary objectForKey:@"C"], @"objectForKey: failed");
    STAssertEquals(0u, [orderedDictionary indexForKey:@"A"], @"indexForKey: failed");
    STAssertEquals(1u, [orderedDictionary indexForKey:@"B"], @"indexForKey: failed");
    STAssertEquals(2u, [orderedDictionary indexForKey:@"C"], @"indexForKey: failed");
}

@end
