//
//  CWOrderedDictionary.h
//  CWFoundation
//  Created by Fredrik Olsson 
//
//  Copyright (c) 2011, Jayway AB All rights reserved.
//  Copyright (c) 2012, Fredrik Olsson All rights reserved.
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

#import <Foundation/Foundation.h>

/*!
 * @abstract CWOrderedDictionary is a subclass of NSMutableDictionary providing
 *           stable ordering for keys.
 *
 * @discussion Keys are ordered with the last inserted key/value pair ordered last.
 *             Key order for ordered initializers are retained. Keys initialized from
 *             an unordered NSDictionary are undefined but stable.
 *
 *             All methods inheritet from NSMutableDictinary and NSDictionary
 *             worls as expected, except that any method providing access to 
 *             keys and values do so in with stable ordering. Eg. allKeys,
 *             allValue and fast enumeration always return objects in the same
 *             predictable order.
 */
@interface CWOrderedDictionary : NSMutableDictionary {
@private
    NSMutableDictionary* _dictionary;
    NSMutableArray* _array;
}

-(void)insertObject:(id)object forKey:(id)key atIndex:(NSUInteger)index;
-(void)removeObjectAtIndex:(NSUInteger)index;
-(void)moveObjectForKey:(id)key toIndex:(NSUInteger)index;

-(id)keyAtIndex:(NSUInteger)index;
-(id)objectAtIndex:(NSUInteger)index;
-(NSUInteger)indexForKey:(id)key;
-(NSIndexSet*)allIndexesForObject:(id)object;

-(void)sortByKeyUsingDescriptors:(NSArray*)sortDescriptors;
#if NS_BLOCKS_AVAILABLE
-(void)sortByKeyUsingComparator:(NSComparator)cmptr;
-(void)sortByKeyWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;
#endif
-(void)sortByKeyUsingFunction:(NSInteger(*)(id, id, void*))compare context:(void*)context;
-(void)sortByKeyUsingSelector:(SEL)comparator;

-(void)sortByValueUsingSelector:(SEL)comparator;
#if NS_BLOCKS_AVAILABLE
-(void)sortByValueUsingComparator:(NSComparator)cmptr;
-(void)sortByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;
#endif

@end
