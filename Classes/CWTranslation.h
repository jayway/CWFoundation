//
//  CWTranslation.h
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

typedef NS_ENUM(NSInteger, CWTranslationAction) {
    CWTranslationActionRequire,
    CWTranslationActionAssign,
    CWTranslationActionAppend
} ;

typedef NS_ENUM(NSInteger, CWTranslationSourceType) {
    CWTranslationSourceTypeAny,
    CWTranslationSourceTypeAttribute,
    CWTranslationSourceTypeValue
} ;


extern NSString* const CWTranslationRootMarker;

/*!
 * @abstract Helper class for reading translation definitions for CWTranslator.
 *
 * @discussion A tree of CWTranslation instances are used by CWTranslator to 
 *             drive the translation process.
 *             You need not care unless you create a new CWTranslator subclass that
 *             has a very different behaviour than CWXMLTranslator or CWJSONTranslator.
 */
@interface CWTranslation : NSObject {
@private
    NSMutableSet* _valueSourceNames;
    NSMutableSet* _attributeSourceNames;
    CWTranslationAction _action;
    NSString* _destinationKey;
    Class _destinationClass;
    NSString* _context;
    NSMutableSet* _subTranslations;
}

/*!
 * @abstract Deserialize a translation definition for a resource name.
 *
 * @discussion Resource is fetched using normal bundle resource rules.
 *			   A file with path extension .xmltranslation is parsed according to rules
 *			   detailed in the class description.
 *			   
 *             Any other file is deserialized as a property list.
 *
 * @param name Name of translation, should NOT include path extension.
 * 
 * @throws NSInvalidArgumentException if translation could not be found or is invalid.
 */
+(CWTranslation*)translationNamed:(NSString*)name;

/*!
 * @abstract Deserialize a translation definition from an string.
 *
 * @throws NSInvalidArgumentException if translation is invalid.
 */
+(CWTranslation*)translationWithDSLString:(NSString*)dslString;

@end
