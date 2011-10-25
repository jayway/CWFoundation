//
//  CWXMLTranslator.m
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
#import "CWXMLTranslator.h"
#import "CWTranslation.h"
#import "CWTranslatorPrivate.h"



@implementation CWXMLTranslator

#pragma mark --- Instance life cycle

-(void)dealloc;
{
  [currentText release];
  [super dealloc];
}


#pragma mark --- Public API

-(NSArray*)translateWithXMLParser:(NSXMLParser*)parser error:(NSError**)error;
{
  [parser setDelegate:self];
  [self beginTranslation];
  if ([parser parse]) {
    return [self rootObjects];
  } else if (error) {
    *error = [parser parserError];
  }
  NSLog(@"Unparsable data in %@ error: %@", parser, [parser parserError]);
  return nil;
}

-(NSArray*)translateContentsOfData:(NSData*)data error:(NSError**)error;
{
  NSXMLParser* parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
  if (parser) {
    return [self translateWithXMLParser:parser
                                  error:error];
  }
	return nil;
}

-(NSArray*)translateContentsOfURL:(NSURL*)url error:(NSError**)error;
{
  NSXMLParser* parser = [[[NSXMLParser alloc] initWithContentsOfURL:url] autorelease];
  if (parser) {
    return [self translateWithXMLParser:parser
                                  error:error];
  }
	return nil;
}

#pragma mark --- Private helpers


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
  [self startGroupingWithName:elementName attributes:attributeDict];
  [currentText release], currentText = [[NSMutableString alloc] initWithCapacity:32];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
  [currentText appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
  NSString *endingText = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  [self endGroupingWithName:elementName text:endingText];
}


@end
