//
//  CWTranslatorPrivate.h
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
#import <Foundation/Foundation.h>
#import "CWTranslator.h"


/*!
 * @abstract Private helper class for CWTranslator.
 */
@interface CWTranslatorState : NSObject {
@private
}

@property(nonatomic, copy) NSString* sourceName;
@property(nonatomic, retain) CWTranslation* translation;
@property(nonatomic, assign) NSUInteger nestingDepth;
@property(nonatomic, retain) id object;
@property(nonatomic, retain) NSDictionary* attributes;

@end


/*!
 * @abstract Private interface needed for CWTranslation and CWTranslator to co-exist.
 */
@interface CWTranslation ()

@property(nonatomic, readonly, retain) NSSet* sourceNames;

@property(nonatomic, readwrite, retain) NSMutableSet* valueSourceNames;
@property(nonatomic, readwrite, retain) NSMutableSet* attributeSourceNames;
@property(nonatomic, readwrite, assign) CWTranslationAction action;
@property(nonatomic, readwrite, copy) NSString* destinationKeyPath;
@property(nonatomic, readwrite, assign) Class destinationClass;
@property(nonatomic, readwrite, copy) NSString* context;
@property(nonatomic, readwrite, retain) NSSet* subTranslations;

-(CWTranslation*)subTranslationForSourceName:(NSString*)name type:(CWTranslationSourceType)type;

-(BOOL)isAtomic;

@end


/*!
 * @abstract Override points for concrete CWTranslator subclasses.
 */
@interface CWTranslator ()

// Must be called by subclasses.
-(void)beginTranslation;
-(NSArray*)rootObjects;

// Must be overridden by subclasses.
-(void)startGroupingWithName:(NSString*)name attributes:(NSDictionary*)attributes;
-(void)endGroupingWithName:(NSString*)name text:(NSString*)text;

@end
