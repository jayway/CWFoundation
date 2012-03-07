//
//  NSValueTransformer+CWAdditions.m
//  CWFoundation
//  Created by Fredrik Olsson 
//
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
#import "NSValueTransformer+CWAdditions.h"
#import <objc/runtime.h>

static NSMutableDictionary* _blockValueTransformerClasses;
static NSMutableDictionary* _dictValueTransformerClasses;

@interface CWBlockValueTransformer : NSValueTransformer {
@private
    CWValueTranformerBlock _block;
}

- (id)initWithBlock:(CWValueTranformerBlock)block;

@end

@interface CWDictionaryValueTransformer : NSValueTransformer {
@private
    NSDictionary *_dictionary;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end


@implementation NSValueTransformer (CWAdditions)


+ (NSValueTransformer *)valueTransformerWithValueClass:(Class)aClass block:(CWValueTranformerBlock)block;
{
    if (_blockValueTransformerClasses == nil) {
        _blockValueTransformerClasses = [[NSMutableDictionary alloc] initWithCapacity:32];
    }
    Class transformerClass = [_blockValueTransformerClasses objectForKey:aClass];
    if (!transformerClass) {
        Class baseClass = [CWBlockValueTransformer class];
        NSString *className = [NSStringFromClass(baseClass) stringByAppendingString:NSStringFromClass(aClass)];
        transformerClass = objc_allocateClassPair(baseClass, [className UTF8String], 0);
        objc_registerClassPair(transformerClass);
        [_blockValueTransformerClasses setObject:transformerClass forKey:aClass];
    }
    return [[transformerClass alloc] initWithBlock:block];
}

+ (NSValueTransformer *)valueTransformerWithValueClass:(Class)aClass dictionary:(NSDictionary *)dictionary;
{
    if (_dictValueTransformerClasses == nil) {
        _dictValueTransformerClasses = [[NSMutableDictionary alloc] initWithCapacity:32];
    }
    Class transformerClass = [_dictValueTransformerClasses objectForKey:aClass];
    if (!transformerClass) {
        Class baseClass = [CWDictionaryValueTransformer class];
        NSString *className = [NSStringFromClass(baseClass) stringByAppendingString:NSStringFromClass(aClass)];
        transformerClass = objc_allocateClassPair(baseClass, [className UTF8String], 0);
        objc_registerClassPair(transformerClass);
        [_dictValueTransformerClasses setObject:transformerClass forKey:aClass];
    }
    return [[transformerClass alloc] initWithDictionary:dictionary];
}

@end


@implementation CWBlockValueTransformer

+ (Class)transformedValueClass;
{
    Class valueClass = [[_blockValueTransformerClasses allKeysForObject:self] lastObject];
    return valueClass;
}

- (id)initWithBlock:(CWValueTranformerBlock)block;
{
    self = [self init];
    if (self) {
        _block = block;
    }
    return self;
}

- (id)transformedValue:(id)value;
{
    return _block(value);
}

@end


@implementation CWDictionaryValueTransformer

+ (Class)transformedValueClass;
{
    Class valueClass = [[_dictValueTransformerClasses allKeysForObject:self] lastObject];
    return valueClass;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [self init];
    if (self) {
        _dictionary = dictionary;
    }
    return self;
}

- (id)transformedValue:(id)value;
{
    return [_dictionary objectForKey:value];
}

@end