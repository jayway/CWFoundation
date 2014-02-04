//
//  CWOrderedDictionary.m
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

#import "CWOrderedDictionary.h"


@implementation CWOrderedDictionary

#pragma mark --- All initializers need to  be overridden for a class cluster :(

-(id)init;
{
    return [self initWithDictionary:[NSDictionary dictionary]];
}

-(id)initWithDictionary:(NSDictionary*)dictionary;
{
    return [self initWithDictionary:dictionary copyItems:NO];
}

-(id)initWithDictionary:(NSDictionary*)dictionary copyItems:(BOOL)copyItems;
{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary copyItems:copyItems];
        _array = [[NSMutableArray alloc] initWithArray:[dictionary allKeys]];
    }
    return self;
}

-(id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;
{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
        _array = [[NSMutableArray alloc] initWithArray:keys];
    }
    return self;
}

-(id)initWithObjects:(id*)objectBuf forKeys:(id*)keyBuf count:(NSUInteger)count;
{
    NSArray* objects = [NSArray arrayWithObjects:objectBuf count:count];
    NSArray* keys = [NSArray arrayWithObjects:keyBuf count:count];
    return [self initWithObjects:objects forKeys:keys];
}

-(id)initWithObjectsAndKeys:(id)firstObject , ...;
{
    NSMutableArray* objects = [NSMutableArray array];
    NSMutableArray* keys = [NSMutableArray array];
    id object = firstObject;
    va_list args;
    va_start(args, firstObject);
    while (object) {
        id key = va_arg(args, id);
        if (key == nil) {
            [NSException raise:NSInvalidArgumentException
                        format:@"nil key"];
        }
        [objects addObject:object];
        [keys addObject:key];
        object = va_arg(args, id);
    }
    va_end(args);
    return [self initWithObjects:objects forKeys:keys];
}

-(id)initWithCapacity:(NSUInteger)capacity;
{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        _array = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}


#pragma mark --- Required for subclassing NSMutableDictionary

-(NSUInteger)count;
{
    return [_array count];
}

-(id)objectForKey:(id)key;
{
    return [_dictionary objectForKey:key];
}

-(NSEnumerator*)keyEnumerator;
{
    return [_array objectEnumerator];
}

-(void)setObject:(id)object forKey:(id)key;
{
    if (![_dictionary objectForKey:key]) {
        [_array addObject:key];
    }
    [_dictionary setObject:object forKey:key];
}

-(void)removeObjectForKey:(id)key;
{
    [_dictionary removeObjectForKey:key];
    [_array removeObject:key];
}

#pragma mark --- Required for conformaing to NSObject, NSCoding, and NSCopying properly

-(id)initWithCoder:(NSCoder *)aDecoder;
{
	self = [super initWithCoder:aDecoder];
    if (self) {
    	_dictionary = [aDecoder decodeObjectForKey:@"CWOrderedDictionary.dictionary"];
    	_array = [aDecoder decodeObjectForKey:@"CWOrderedDictionary.array"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
 	[aCoder encodeObject:_dictionary forKey:@"CWOrderedDictionary.dictionary"];
    [aCoder encodeObject:_array forKey:@"CWOrderedDictionary.array"];
    [super encodeWithCoder:aCoder];
}

-(id)copyWithZone:(NSZone*)zone;
{
	return [[[self class] alloc] initWithDictionary:self];
}

-(id)mutableCopyWithZone:(NSZone*)zone;
{
	return [self copyWithZone:zone];
}

-(NSUInteger)hash;
{
	return [_dictionary hash] ^ [_array hash];
}

-(BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary;
{
	if ([otherDictionary isKindOfClass:[CWOrderedDictionary class]]) {
    	CWOrderedDictionary* otherOrderedDictionary = (id)otherDictionary;
        if ([_dictionary isEqualToDictionary:otherOrderedDictionary->_dictionary]) {
        	return [_array isEqualToArray:otherOrderedDictionary->_array];
        }
    }
    return NO;
}

#pragma mark --- For a nice description

static NSString* CWDescriptionForObject(id object, id locale, NSUInteger indent)
{
	if ([object isKindOfClass:[NSString class]]) {
		return object;
	} else if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)]) {
		return [object descriptionWithLocale:locale indent:indent];
	} else if ([object respondsToSelector:@selector(descriptionWithLocale:)]) {
		return [object descriptionWithLocale:locale];
    } else {
		return [object description];
	}
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
	NSMutableString* indentString = [NSMutableString string];
	for (NSUInteger i = 0; i < level; i++) {
		[indentString appendFormat:@"    "];
	}	
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"%@{\n", indentString];
	for (id key in self) {
		[description appendFormat:@"%@    %@ = %@;\n",
        	indentString,
         	CWDescriptionForObject(key, locale, level),
         	CWDescriptionForObject([self objectForKey:key], locale, level)];
	}
	[description appendFormat:@"%@}\n", indentString];
	return description;
}


#pragma mark --- Public API

-(void)insertObject:(id)object forKey:(id)key atIndex:(NSUInteger)index;
{
    NSUInteger oldIndex = [self indexForKey:key];
    if (oldIndex == NSNotFound) {
        [_dictionary setObject:object forKey:key];
        [_array insertObject:key atIndex:index];
    } else {
        [NSException raise:NSInvalidArgumentException
                    format:@"Cannot insert object with key %@ at index %d, already exist at index %d", key, index, oldIndex];
    }
}

-(void)removeObjectAtIndex:(NSUInteger)index;
{
    [self removeObjectForKey:[_array objectAtIndex:index]];
}

-(void)moveObjectForKey:(id)key toIndex:(NSUInteger)index;
{
	NSUInteger oldIndex = [_array indexOfObject:key];
    if (oldIndex == NSNotFound) {
        [NSException raise:NSInvalidArgumentException
                    format:@"No object for key %@", key];
    } else if (oldIndex != index) {
        [_array removeObjectAtIndex:oldIndex];
        [_array insertObject:key atIndex:index];
    } else {
        // Same index, no-op
    }
}

-(id)keyAtIndex:(NSUInteger)index;
{
    return [_array objectAtIndex:index]; 
}

-(id)objectAtIndex:(NSUInteger)index;
{
    return [_dictionary objectForKey:[_array objectAtIndex:index]];
}

-(NSUInteger)indexForKey:(id)key;
{
    return [_array indexOfObject:key];
}

-(NSIndexSet*)allIndexesForObject:(id)object;
{
    NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
    for (id key in [_dictionary allKeysForObject:object]) {
        [indexes addIndex:[_array indexOfObject:key]];
    }
    return [[NSIndexSet alloc] initWithIndexSet:indexes];
}

#pragma mark --- Sort methods

-(void)sortByKeyUsingDescriptors:(NSArray*)sortDescriptors;
{
	[_array sortUsingDescriptors:sortDescriptors];    
}

#if NS_BLOCKS_AVAILABLE
-(void)sortByKeyUsingComparator:(NSComparator)cmptr;
{
	[_array sortUsingComparator:cmptr];    
}

-(void)sortByKeyWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;
{
	[_array sortWithOptions:opts usingComparator:cmptr];    
}

#endif

-(void)sortByKeyUsingFunction:(NSInteger(*)(id, id, void*))compare context:(void*)context;
{
	[_array sortUsingFunction:compare context:context];    
}

-(void)sortByKeyUsingSelector:(SEL)comparator;
{
	[_array sortUsingSelector:comparator];
}

-(void)sortByValueUsingSelector:(SEL)comparator;
{
    _array = [[NSMutableArray alloc] initWithArray:[_dictionary keysSortedByValueUsingSelector:comparator]];
}

#if NS_BLOCKS_AVAILABLE
-(void)sortByValueUsingComparator:(NSComparator)cmptr;
{
    _array = [[NSMutableArray alloc] initWithArray:[_dictionary keysSortedByValueUsingComparator:cmptr]];
}

-(void)sortByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;
{
    _array = [[NSMutableArray alloc] initWithArray:[_dictionary keysSortedByValueWithOptions:opts 
                                                                             usingComparator:cmptr]];
}
#endif


#pragma mark --- Faster implementations of wrapper method

-(NSArray*)allKeys;
{
    return [NSArray arrayWithArray:_array];
}

-(NSArray*)allValues;
{
    NSMutableArray* values = [NSMutableArray arrayWithCapacity:[_array count]];
    for (id key in _array) {
        [values addObject:[_dictionary objectForKey:key]];
    }
    return [NSArray arrayWithArray:values];
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len;
{
    return [_array countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
