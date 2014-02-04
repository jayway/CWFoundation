//
//  CWTranslator.m
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
#import "CWTranslator.h"
#import "CWTranslatorPrivate.h"

@implementation CWTranslatorState

@synthesize sourceName, translation, nestingDepth, object, sourceText, attributes;

@end


@implementation CWTranslator

#pragma mark --- Properties

@synthesize delegate = _delegate;

-(void)setDelegate:(id<CWTranslatorDelegate>)delegate;
{
	if (_delegate != delegate) {
    	_delegate = delegate;
    	_delegateFlags.objectInstanceOfClass = [delegate respondsToSelector:@selector(translator:objectInstanceForTranslatorState:shouldSkip:)];
    	_delegateFlags.didTranslateObject = [delegate respondsToSelector:@selector(translator:didTranslateObject:fromTranslatorState:ontoObject:)];
    	_delegateFlags.atomicObjectInstanceOfClass = [delegate respondsToSelector:@selector(translator:atomicObjectInstanceFromTranslatorState:shouldSkip:)];
    }
}

static NSDateFormatter* _defaultDateFormatter = nil;

+ (NSDateFormatter*) defaultDateFormatter;
{
	if (_defaultDateFormatter == nil) {
		_defaultDateFormatter = [[NSDateFormatter alloc] init];
        [_defaultDateFormatter setLenient:YES];
	}
	return _defaultDateFormatter;
}

+ (void) setDefaultDateFormatter:(NSDateFormatter *)formatter;
{
    _defaultDateFormatter = formatter;
}

+(NSArray*)translateContentsOfData:(NSData*)data withTranslationNamed:(NSString*)translationName delegate:(id<CWTranslatorDelegate>)delegate error:(NSError**)error;
{ 
    CWTranslation* translation = [CWTranslation translationNamed:translationName];
    CWTranslator* translator = [[self alloc] initWithTranslation:translation delegate:delegate];
    return [translator translateContentsOfData:data error:error];
}

+(NSArray*)translateContentsOfURL:(NSURL*)url withTranslationNamed:(NSString*)translationName delegate:(id<CWTranslatorDelegate>)delegate error:(NSError**)error;
{
    CWTranslation* translation = [CWTranslation translationNamed:translationName];
    CWTranslator* translator = [[self alloc] initWithTranslation:translation delegate:delegate];
    return [translator translateContentsOfURL:url error:error];    
}

-(id)initWithTranslation:(CWTranslation*)translation delegate:(id<CWTranslatorDelegate>)delegate;
{
    self = [self init];
    if (self) {
        self.delegate = delegate;
        rootTranslation = translation;
        stateStack = [[NSMutableArray alloc] initWithCapacity:16];
        rootObjects = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

-(NSArray*)translateContentsOfData:(NSData*)data error:(NSError**)error;
{
    [NSException raise:NSInternalInconsistencyException 
                format:@"%@ not overriden in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])];
    return nil;
}

-(NSArray*)translateContentsOfURL:(NSURL*)url error:(NSError**)error;
{
    [NSException raise:NSInternalInconsistencyException 
                format:@"%@ not overriden in %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])];
    return nil;
}

-(void)beginTranslation;
{
    [rootObjects removeAllObjects];
    [stateStack removeAllObjects];
    CWTranslatorState* state = [[CWTranslatorState alloc] init];
    if (rootTranslation.sourceNames) {
        CWTranslation* translation = [[CWTranslation alloc] init];
        [translation setValue:[NSSet setWithObject:rootTranslation] forKey:@"subTranslations"];
        state.translation = translation;
    } else {
        state.translation = rootTranslation;
    }
    [stateStack addObject:state];
}

-(NSArray*)rootObjectsWithError:(NSError**)error;
{
    if (_error && error) {
        *error = _error;
    }
    return [NSArray arrayWithArray:rootObjects];
}

-(void)setError:(NSError*)error;
{
    _error = error;
}

-(id)objectInstanceFromTranslatorState:(CWTranslatorState *)state;
{
    id result = nil;
    BOOL shouldSkip = NO;
    if (_delegateFlags.objectInstanceOfClass) {
        result = [_delegate translator:self
      objectInstanceForTranslatorState:state
                            shouldSkip:&shouldSkip];
    }
    if (result == nil && !shouldSkip) {
        result = [[state.translation.destinationClass alloc] init];
    }
    return result;
}

-(id)atomicObjectInstanceFromTranslatorState:(CWTranslatorState *)state;
{
    id result = nil;
    BOOL shouldSkip = NO;
    if (_delegateFlags.atomicObjectInstanceOfClass) {
        result = [_delegate translator:self
atomicObjectInstanceFromTranslatorState:state
                            shouldSkip:&shouldSkip];
    }
    if (result == nil && !shouldSkip) {
        Class aClass = state.translation.destinationClass;
        NSString *aString = state.sourceText;
        NSValueTransformer *transformer = state.translation.valueTransformer;
        if (transformer) {
            return [transformer transformedValue:aString];
        }
        if (aClass == [NSString class]) {
            return aString;
        } else if (aClass == [NSNumber class]) {
            result = [NSDecimalNumber decimalNumberWithString:aString];
            if (result == nil || [result isEqualToNumber:[NSDecimalNumber notANumber]]) {
                if ([aString caseInsensitiveCompare:@"true"] == NSOrderedSame || [aString caseInsensitiveCompare:@"yes"] == NSOrderedSame) {
                    result = [NSNumber numberWithBool:YES];
                } else if ([aString caseInsensitiveCompare:@"false"] == NSOrderedSame || [aString caseInsensitiveCompare:@"no"] == NSOrderedSame) {
                    result = [NSNumber numberWithBool:NO];
                }
            }
        } else if (aClass == [NSDate class]) {
            result = [[[self class] defaultDateFormatter] dateFromString:aString];
        } else {
            result = [[aClass alloc] initWithString:aString];
        }
    }
	return result;
}

-(id)didTranslateObject:(id)anObject fromTranslatorState:(CWTranslatorState *)state ontoObject:(id)parentObject;
{
    if (_delegateFlags.didTranslateObject) {
        anObject = [_delegate translator:self
                      didTranslateObject:anObject
                     fromTranslatorState:state
                              ontoObject:parentObject];
    }
	return anObject;
}

-(void)attachObject:(id)object onParentObject:(id)parent withTranslatorState:(CWTranslatorState *)state;
{
    if (state.translation.destinationKeyPath == CWTranslationRootMarker) {
        parent = nil;
    }
    object = [self didTranslateObject:object fromTranslatorState:state ontoObject:parent];
    if (object) {
        if (parent == nil) {
            [rootObjects addObject:object];
        } else {
            NSString* key = state.translation.destinationKeyPath;
            switch (state.translation.action) {
                case CWTranslationActionAssign:
                    [parent setValue:object forKeyPath:key];
                    break;
                case CWTranslationActionAppend:
                    if ([parent isKindOfClass:NSClassFromString(@"NSManagedObject")]) {
                        [[parent mutableSetValueForKeyPath:key] addObject:object];
                    } else {
                        [[parent mutableArrayValueForKeyPath:key] addObject:object];
                    }
                default:
                    break;
            }
        }
    }
}

- (void)attachAttributesOntoObject:(id)object withTranslatorState:(CWTranslatorState *)state;
{
    [state.attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        CWTranslation* subTranslation = [state.translation subTranslationForSourceName:key type:CWTranslationSourceTypeAttribute];
        if (subTranslation) {
            CWTranslatorState *subState = [[CWTranslatorState alloc] init];
            subState.sourceName = key;
            subState.sourceText = obj;
            subState.translation = subTranslation;
            id subObject = [self atomicObjectInstanceFromTranslatorState:subState];
            if (subObject) {
                [self attachObject:subObject
                    onParentObject:object
               withTranslatorState:subState];
            }
        }
    }];
}

-(id)currentParentObject;
{
    for (int i = [stateStack count] - 2; i >= 0; i--) {
        CWTranslatorState* parentState = [stateStack objectAtIndex:i];
        if (parentState.object) {
            return parentState.object;
        }
    }
    return nil;
}

-(void)startGroupingWithName:(NSString*)name attributes:(NSDictionary*)attributes;
{
    CWTranslatorState* state = [stateStack lastObject];
    CWTranslation* translation = [state.translation subTranslationForSourceName:name type:CWTranslationSourceTypeValue];
    if (translation) {
        if (translation.action == CWTranslationActionRequire) {
            state = [[CWTranslatorState alloc] init];
            state.sourceName = name;
            state.translation = translation;
            state.attributes = attributes;
            [stateStack addObject:state];
            id parent = [self currentParentObject];
            [self attachAttributesOntoObject:parent 
                         withTranslatorState:state];
            return;
        } else if ([translation isAtomic]) {
            state = [[CWTranslatorState alloc] init];
            state.sourceName = name;
            state.translation = translation;
            state.attributes = attributes;
            [stateStack addObject:state];
            return;
        } else {
            state = [[CWTranslatorState alloc] init];
            state.sourceName = name;
            state.translation = translation;
            state.attributes = attributes;
            id object = [self objectInstanceFromTranslatorState:state];
            if (object) {
                state.object = object;
                [stateStack addObject:state];
                [self attachAttributesOntoObject:object
                             withTranslatorState:state];
                return;
            } else {
                state = [stateStack lastObject];
            }
        }
    }
    if ([state.sourceName isEqualToString:name]) {
        state.nestingDepth++;
    }
}

-(void)endGroupingWithName:(NSString*)name text:(NSString*)text;
{
    CWTranslatorState* state = [stateStack lastObject];
    if ([state.sourceName isEqualToString:name]) {
        if (state.nestingDepth > 0) {
            state.nestingDepth--;
            return;
        }
        CWTranslation* translation = state.translation;
        if (translation.action != CWTranslationActionRequire) {
            if ([translation isAtomic]) {
                state.sourceText = text;
                state.object = [self atomicObjectInstanceFromTranslatorState:state];
            }
            id parent = [self currentParentObject];
            [self attachObject:state.object
                onParentObject:parent
           withTranslatorState:state];
        }
        [stateStack removeLastObject];
    }
}

@end
