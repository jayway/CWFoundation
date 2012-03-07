//
//  CWTranslator.h
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
#import <Foundation/Foundation.h>
#import "CWTranslation.h"

@protocol CWTranslatorDelegate;



/*!
 * @abstract A base class for implementing translators from structured data to domain objects.
 *
 * @discussion This class is abstract, use the concrete subclasses CWXMLTranslator or CWJSONTranslator.
 */
@interface CWTranslator : NSObject {
@private
    __weak id<CWTranslatorDelegate> _delegate;
    CWTranslation* rootTranslation;
	NSMutableArray* stateStack;
	NSMutableArray* rootObjects;
    NSError* _error;
    struct {
    	unsigned int objectInstanceOfClass:1;
    	unsigned int didTranslateObject:1;
    	unsigned int atomicObjectInstanceOfClass:1;
    } _delegateFlags;
}

/*!
 * @abstract The translation delegate.
 * @discussion The delegate methods are always called on the same thread that the translation was started from.
 */
@property(nonatomic, weak) id<CWTranslatorDelegate> delegate;

/*!
 * @abstract The default NSDateFormatter
 * @discussion Used when translating strings to NSDate.
 */
+ (NSDateFormatter*) defaultDateFormatter;
+ (void) setDefaultDateFormatter:(NSDateFormatter *)formatter;

/*!
 * @abstract Convinience method for translating XML with a translation and delagate.
 * @throws NSInvalidArgumentException if translation could not be found or is invalid.
 */
+(NSArray*)translateContentsOfData:(NSData*)data withTranslationNamed:(NSString*)translation delegate:(id<CWTranslatorDelegate>)delegate error:(NSError**)error;

/*!
 * @abstract Convinience method for translating XML with a translation and delagate.
 * @throws NSInvalidArgumentException if translation could not be found or is invalid.
 */
+(NSArray*)translateContentsOfURL:(NSURL*)url withTranslationNamed:(NSString*)translation delegate:(id<CWTranslatorDelegate>)delegate error:(NSError**)error;

/*!
 * @abstract Init translator with delegate to send created root objects to.
 */
-(id)initWithTranslation:(CWTranslation*)translation delegate:(id<CWTranslatorDelegate>)delegate;

/*!
 * @abstract Translate the XML document in data using a delegate and an optional out error argument.
 */
-(NSArray*)translateContentsOfData:(NSData*)data error:(NSError**)error;

/*!
 * @abstract Translate the XML document referenced by an URL using a default delegate and an optional out error argument.
 */
-(NSArray*)translateContentsOfURL:(NSURL*)url error:(NSError**)error;

@end


/*!
 * @abstract Delegate for handling he result of a XML transltion.
 */
@protocol CWTranslatorDelegate <NSObject>

@optional

/*!
 * @abstract Implement for custom instantiation of an object of a given class.
 *
 * @discussion Return an autoreleased and initialized object if you need a custom object initialization.
 *             Otherwise return nil, to let the translator instantiate using [[aClass alloc] init].
 *
 * @param translator the XML translator
 * @param aClass the proposed class to instantiate.
 * @param name the XML element name.
 * @param attributes the XML attributes for the XML element.
 * @param key the key to later set the result to, or nil if a root object.
 * @param skip an out parameter, set to YES if this translation should be skipped for any reason.
 * @result an object instantiated usingt he arguments, or nil if a default object should be instantiated.
 */
-(id)translator:(CWTranslator*)translator objectInstanceOfClass:(Class)aClass fromSourceName:(NSString*)name attributes:(NSDictionary*)attributes toKeyPath:(NSString*)key context:(NSString*)context shouldSkip:(BOOL*)skip;

/*!
 * @abstract Translator did translate an obejct for a specified key.
 *
 * @discussion Called before assigning to the target. Delegate may replace the object, or return nil if the object
 *             should not be set to it's parent ot be added to the root object array.
 */
-(id)translator:(CWTranslator*)translator didTranslateObject:(id)anObject fromSourceName:(NSString*)name attributes:(NSDictionary*)attributes toKeyPath:(NSString*)key ontoObject:(id)parentObject context:(NSString*)context;

/*!
 * @abstract Implement custom instansiation of a value object of a given class.
 *
 * @discussion Return an autoreleased and initialized object if you need a custom object initialization.
 *             Otherwise return nil, to let the translator instantiate using [[aClass alloc] init].
 *
 * @param translator the XML translator
 * @param aClass the proposed class to instantiate.
 * @param name the XML element or attribute name.
 * @param attributes the XML attributes for the XML element, or nil if instantiating from an attribute.
 * @param key the key to later set the result to, or nil if a root object.
 * @param skip an out parameter, set to YES if this translation should be skipped for any reason.
 * @result an object instantiated usingt he arguments, or nil if a default object should be instantiated.
 */
-(id)translator:(CWTranslator*)translator atomicObjectInstanceOfClass:(Class)aClass withString:(NSString*)aString fromSourceName:(NSString*)name attributes:(NSDictionary*)attributes toKeyPath:(NSString*)key context:(NSString*)context shouldSkip:(BOOL*)skip;


@end
