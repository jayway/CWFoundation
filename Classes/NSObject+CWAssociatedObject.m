//
//  NSObject+CWAssociatedObject.m
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

#import "NSObject+CWAssociatedObject.h"
#import "CWLog.h"
#import <objc/runtime.h>

#if CW_SUPPORT_LEGACY_ASSOCIATED_OBJECTS || CW_FORCE_LEGACY_ASSOCIATED_OBJECTS

// A marker class to support assign policy for legacy associated objects.
@interface CWIDValue : NSObject { id value; }
+(id)IDValueWithID:(id)value;
-(id)value;
@end
@implementation CWIDValue
+(id)IDValueWithID:(id)value;
{
    CWIDValue* result = [[[CWIDValue alloc] init] autorelease];
    result->value = value;
    return result;
}
-(id)value;
{
	return value;
}
@end

#endif

@implementation NSObject (CWAssociatedObject)

#if CW_SUPPORT_LEGACY_ASSOCIATED_OBJECTS || CW_FORCE_LEGACY_ASSOCIATED_OBJECTS

static NSMutableDictionary* cw_associatedObjects = nil;

+(void)exchangeInstanceMethodImplementationsForSelector:(SEL)s1 andSelector:(SEL)s2;
{
	Method m1 = class_getInstanceMethod(self, s1);
    Method m2 = class_getInstanceMethod(self, s2);
    method_exchangeImplementations(m1, m2);
}

+(void)load;
{
#if !CW_FORCE_LEGACY_ASSOCIATED_OBJECTS
#if TARGET_OS_IPHONE
    double minVersion = NSFoundationVersionNumber_iPhoneOS_3_1;
#else
    double minVersion = NSFoundationVersionNumber10_6;
#endif
	if (NSFoundationVersionNumber < minVersion) {
#endif
        CWLogWarning(@"Uses legacy compatible associated objects");
        cw_associatedObjects = [[NSMutableDictionary alloc] init];
        [self exchangeInstanceMethodImplementationsForSelector:@selector(associatedObjectForStaticKey:) 
                                                   andSelector:@selector(legacy_associatedObjectForStaticKey:)];
        [self exchangeInstanceMethodImplementationsForSelector:@selector(setAssociatedObject:forStaticKey:) 
                                                   andSelector:@selector(legacy_setAssociatedObject:forStaticKey:)];
        [self exchangeInstanceMethodImplementationsForSelector:@selector(setAssociatedObject:forStaticKey:withAssociationPolicy:) 
                                                   andSelector:@selector(legacy_setAssociatedObject:forStaticKey:withAssociationPolicy:)];
		if (!NSClassFromString(@"SenTestCase")) {
            [self exchangeInstanceMethodImplementationsForSelector:@selector(dealloc)
                                                       andSelector:@selector(legacy_associated_objects_dealloc)];
		} else {
            CWLogWarning(@"Will leak associated objects when run under SenTest harness");
        }
#if !CW_FORCE_LEGACY_ASSOCIATED_OBJECTS
    }
#endif
}

-(void)legacy_associated_objects_dealloc;
{
	[cw_associatedObjects removeObjectForKey:[NSValue valueWithPointer:self]];
    [self legacy_associated_objects_dealloc];
}

-(id)legacy_associatedObjectForStaticKey:(void*)key;
{
    id object = nil;
    @synchronized(self) {
	    NSMutableDictionary* objects = [cw_associatedObjects objectForKey:[NSValue valueWithPointer:self]];
    	object = [objects objectForKey:[NSValue valueWithPointer:key]];
        if ([object isKindOfClass:[CWIDValue class]]) {
        	object = [object value];
        }
    }
    return object;
}

-(void)legacy_setAssociatedObject:(id)value forStaticKey:(void*)key;
{
    // Intentionally call non-legacy method since implementations are exchanged at run-time.
    [self setAssociatedObject:value
                 forStaticKey:key 
        withAssociationPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

-(void)legacy_setAssociatedObject:(id)value forStaticKey:(void *)key withAssociationPolicy:(objc_AssociationPolicy)policy; 
{
    @synchronized(self) {
        NSMutableDictionary* objects = [cw_associatedObjects objectForKey:[NSValue valueWithPointer:self]];
        if (objects == nil) {
            objects = [NSMutableDictionary dictionaryWithCapacity:4];
            [cw_associatedObjects setObject:objects forKey:[NSValue valueWithPointer:self]];
        }
        switch (policy) {
            case OBJC_ASSOCIATION_ASSIGN:
                [objects setObject:[CWIDValue IDValueWithID:value]
                            forKey:[NSValue valueWithPointer:key]];
                break;
            case OBJC_ASSOCIATION_COPY:
            case OBJC_ASSOCIATION_COPY_NONATOMIC:
                [objects setObject:[value copy] 
                            forKey:[NSValue valueWithPointer:key]];
                break;
            case OBJC_ASSOCIATION_RETAIN:
            case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
                [objects setObject:value 
                            forKey:[NSValue valueWithPointer:key]];
                break;
        }
    }
}

#endif


-(id)associatedObjectForStaticKey:(void*)key;
{
	return objc_getAssociatedObject(self, key);    
}

-(void)setAssociatedObject:(id)value forStaticKey:(void*)key;
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

-(void)setAssociatedObject:(id)value forStaticKey:(void *)key withAssociationPolicy:(objc_AssociationPolicy)policy; 
{
	objc_setAssociatedObject(self, key, value, policy);
}

@end
