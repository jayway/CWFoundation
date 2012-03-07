//
//  CWTranslaterTests.m
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
#import "CWTranslaterTests.h"
#import "CWXMLTranslator.h"

@implementation CWTranslaterTests


-(void)setUp;
{
	translateObjectCount = 0;
    didTranslateObjectCount = 0;
    translatePrimitiveObjectCount = 0;
    didTranslateWithContextCount = 0;
}

-(CWXMLTranslator*)translatorWithDSLString:(NSString*)dsl;
{
	CWTranslation* translation = nil;
    STAssertNoThrow(translation = [CWTranslation translationWithDSLString:dsl], @"legal DSL");
	STAssertNotNil(translation, @"translation should not be nil");
    CWXMLTranslator* translator = [[CWXMLTranslator alloc] initWithTranslation:translation
                                                                       delegate:nil];
    STAssertNotNil(translator, @"translator should not be nil");
    NSLog(@"translation: %@", translation);
    return translator;
}

-(NSArray*)objectsByTranslatingXMLString:(NSString*)xml withTranslator:(CWXMLTranslator*)translator;
{
    NSError* error = nil;
	NSArray* objects = [translator translateContentsOfData:[xml dataUsingEncoding:NSUTF8StringEncoding]
                                                     error:&error];
	STAssertNotNil(objects, @"objects should not be nil");
    STAssertNil(error, @"error should be nil (%@)", error);
    return objects;
}

-(void)testTranslatorWithSingleTag;
{
	CWXMLTranslator* translator = [self translatorWithDSLString:@"a>>@root;"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml></xml>"
                                            withTranslator:translator];
    STAssertEquals(0u, [objects count], @"Should have no objects");
    
    objects = [self objectsByTranslatingXMLString:@"<xml><b>A</b></xml>"
                                   withTranslator:translator];
    STAssertEquals(0u, [objects count], @"Should have no objects");
    
    objects = [self objectsByTranslatingXMLString:@"<xml><a>A</a></xml>"
                                   withTranslator:translator];
    STAssertEquals(1u, [objects count], @"Should have one object");
    STAssertEqualObjects(@"A", [objects lastObject], @"Object should be 'A'");
    
    objects =  [self objectsByTranslatingXMLString:@"<xml><a>A</a><a>AA</a></xml>"
                                    withTranslator:translator];
    STAssertEquals(2u, [objects count], @"Should have two objects");
    STAssertEqualObjects(@"A", [objects objectAtIndex:0], @"First object should be 'A'");
    STAssertEqualObjects(@"AA", [objects lastObject], @"Last object should be 'AA'");
}

-(void)testTranslatorWithListOfTags;
{
	CWXMLTranslator* translator = [self translatorWithDSLString:@"{a>>@root;b>>@root;}"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml></xml>"
                                            withTranslator:translator];
    STAssertEquals(0u, [objects count], @"Should have no objects");
    
    objects = [self objectsByTranslatingXMLString:@"<xml><a>A</a></xml>"
                                   withTranslator:translator];
    STAssertEquals(1u, [objects count], @"Should have one object");
    STAssertEqualObjects(@"A", [objects lastObject], @"Object should be 'A'");
    
    objects = [self objectsByTranslatingXMLString:@"<xml><b>B</b></xml>"
                                   withTranslator:translator];
    STAssertEquals(1u, [objects count], @"Should have one object");
    STAssertEqualObjects(@"B", [objects lastObject], @"Object should be 'B'");
    
    objects =  [self objectsByTranslatingXMLString:@"<xml><a>A</a><b>B</b></xml>"
                                    withTranslator:translator];
    STAssertEquals(2u, [objects count], @"Should have two objects");
    STAssertEqualObjects(@"A", [objects objectAtIndex:0], @"First object should be 'A'");
    STAssertEqualObjects(@"B", [objects lastObject], @"Last object should be 'B'");
}

-(void)testTranslatorWithStackOfTags;
{
	CWXMLTranslator* translator = [self translatorWithDSLString:@"a>>@root:NSMutableDictionary{b>>b:NSMutableDictionary{c>>c;};};"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a><b><c>C</c></b></a></xml>"
                                            withTranslator:translator];
	STAssertEquals(1u, [objects count], @"Should have one root object (%@)", objects);
    NSDictionary* object = [objects lastObject];
    STAssertTrue([object isKindOfClass:[NSDictionary class]], @"Object is a dictionary");
    STAssertEqualObjects(@"C", [object valueForKeyPath:@"b.c"], @"Leaf object should be 'C'");
}

-(void)testTranslatorDictionaryWithTags;
{
	CWXMLTranslator* translator = [self translatorWithDSLString:@"a>>@root:NSMutableDictionary{b>>b;c>>c};"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a><b>B</b><c>C</c></a></xml>"
                                            withTranslator:translator];
	STAssertEquals(1u, [objects count], @"Should have one root object");
    NSDictionary* object = [objects lastObject];
    STAssertTrue([object isKindOfClass:[NSDictionary class]], @"Object is a dictionary");
	STAssertEquals(2u, [object count], @"Should have two objects (%@)", object);
    STAssertEqualObjects(@"B", [object objectForKey:@"b"], @"Object for key b should be 'B'");
    STAssertEqualObjects(@"C", [object objectForKey:@"c"], @"Object for key c should be 'C'");
}

-(void)testTranslatorDictionaryWithAttributes;
{
	CWXMLTranslator* translator = [self translatorWithDSLString:@"a>>@root:NSMutableDictionary{.b>>b;.c>>c};"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a b='B' c='C'/></xml>"
                                            withTranslator:translator];
	STAssertEquals(1u, [objects count], @"Should have one root object");
    NSDictionary* object = [objects lastObject];
    STAssertTrue([object isKindOfClass:[NSDictionary class]], @"Object is a dictionary");
	STAssertEquals(2u, [object count], @"Should have two objects (%@)", object);
    STAssertEqualObjects(@"B", [object objectForKey:@"b"], @"Object for key b should be 'B'");
    STAssertEqualObjects(@"C", [object objectForKey:@"c"], @"Object for key c should be 'C'");
}

-(void)testTranslatorSkipsCorrectTagNodes;
{
	CWXMLTranslator* translator = [self translatorWithDSLString:@"a ->c>>@root;"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a><c>C</c></a><b><c>D</c></b></xml>"
                                            withTranslator:translator];
	STAssertEquals(1u, [objects count], @"Should have one root object");
    STAssertEqualObjects(@"C", [objects lastObject], @"Object should be 'C'");
}

-(void)testTranslatorSkipIntoTagAndCaptureAttribute;
{
	CWXMLTranslator* translator = [self translatorWithDSLString:@"a ->.a>>@root;"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a a='A'/><b a='B'/></xml>"
                                            withTranslator:translator];
	STAssertEquals(1u, [objects count], @"Should have one root object");
    STAssertEqualObjects(@"A", [objects lastObject], @"Object should be 'B'");
}

-(void)testTranslatorTranslatesURLTag;
{
    CWXMLTranslator* translator = [self translatorWithDSLString:@"a>>@root:NSURL;"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a>http://google.com</a></xml>"
                                            withTranslator:translator];
    STAssertEquals(1u, [objects count], @"Should have one root object");
    NSURL* object = [objects lastObject];
    STAssertTrue([object isKindOfClass:[NSURL class]], @"Object should be an NSURL (%@) (%@)", object, objects);
}

-(void)testTranslatorTranslatesURLAttribute;
{
    CWXMLTranslator* translator = [self translatorWithDSLString:@"a>>@root:NSMutableDictionary{.a>>a:NSURL;};"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a a='http://google.com'/></xml>"
                                            withTranslator:translator];
    STAssertEquals(1u, [objects count], @"Should have one root object");
	NSDictionary* object = [objects lastObject];
    STAssertTrue([object isKindOfClass:[NSDictionary class]], @"Object should be an NSDictionary");
    STAssertEquals(1u, [object count], @"Should have one object (%@)", object);
    STAssertTrue([[object objectForKey:@"a"] isKindOfClass:[NSURL class]], @"Should be an NSURL, is %@", NSStringFromClass([[object objectForKey:@"a"] class]));
}

-(void)testTranslatorMultipleSourcesNames;
{
    CWXMLTranslator* translator = [self translatorWithDSLString:@"a|b>>@root;"];
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a>A</a><b>B</b></xml>" withTranslator:translator];
    STAssertEquals(2u, [objects count], @"Should have two root objects");
}

-(void)testTranslatorWithContext;
{
    CWXMLTranslator* translator = [self translatorWithDSLString:@"{a>>@root(a);b>>@root;}"];
    translator.delegate = self;
    
    NSArray* objects = [self objectsByTranslatingXMLString:@"<xml><a>A</a><b>B</b></xml>" withTranslator:translator];
    STAssertEquals(2u, [objects count], @"Should have two root objects");
    STAssertEquals(2, didTranslateObjectCount, @"Should have translated two objects");
    STAssertEquals(1, didTranslateWithContextCount, @"Should have translated one object with context.");
}

#pragma mark --- Delegate methods

-(id)translator:(CWTranslator *)translator objectInstanceOfClass:(Class)aClass fromSourceName:(NSString *)name attributes:(NSDictionary *)attributes toKeyPath:(NSString *)key context:(NSString *)context shouldSkip:(BOOL *)skip;
{
	translateObjectCount++;
    return nil;
}

-(id)translator:(CWTranslator *)translator didTranslateObject:(id)anObject fromSourceName:(NSString *)name toKeyPath:(NSString *)key ontoObject:(id)parentObject context:(NSString *)context;
{
	didTranslateObjectCount++;
    if (context) {
        didTranslateWithContextCount++;
    }
    return anObject;
}


-(id)translator:(CWTranslator *)translator atomicObjectInstanceOfClass:(Class)aClass withString:(NSString *)aString fromSourceName:(NSString *)name attributes:(NSDictionary *)attributes toKeyPath:(NSString *)key context:(NSString *)context shouldSkip:(BOOL *)skip;
{
    translatePrimitiveObjectCount++;
	return nil;
}

@end
