//
//  NSError+CWAdditions.h
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

/*!
 * @abstract A generic application error.
 */
extern NSString* const CWFoundationAdditionsErrorDomain;

/*!
 * @abstract A generic application error.
 */
extern NSString* const CWApplicationErrorDomain;

@protocol CWErrorRecoveryAttempting;


/*!
 * @abstract Category on NSError adding convinience methods for creating and copying errors.
 */
@interface NSError (CWErrorAdditions) <NSMutableCopying>

/*!
 * @abstract Initialize a copy of the error.
 */
-(instancetype)initWithError:(NSError*)error;

/*!
 * @abstract Create a copy of the error.
 */
+(instancetype)errorWithError:(NSError*)error;

/*!
 * @abstract Return an NSError with localized description and reason.
 */
+(instancetype)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason;

/*!
 * @abstract Return an NSError with localized description, reason and recovery options.
 *
 * @discussion The order of the recovery options are consistent with how AppKit expects
 *			   them for correct display in a NSAlert.
 *			   Index 0 - Default button, eg "Save".
 *			   Index 1 - Alternate button, eg. "Don't Save".
 *			   Index 2 - Other button, eg. "Cancel"
 *			   If only two options are available then the index 1 is treated as index 2.
 */
+(instancetype)errorWithDomain:(NSString *)domainOrNil code:(NSInteger)code 
      localizedDescription:(NSString *)description 
           localizedReason:(NSString *)reason
localizedRecoverySuggestion:(NSString*)suggestionOrNil
         recoveryAttempter:(id<CWErrorRecoveryAttempting>)recoveryAttempterOrNil
  localizedRecoveryOptions:(NSArray*)recoveryOptionsOrNil;

/*!
 * @abstract Get the underlying error that caused this error.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSError *underlyingError;

@end

/*!
 * @abstract A mutable subclass of NSError.
 */
@interface NSMutableError : NSError {
@private
    NSMutableDictionary* _mutableUserInfo;
}

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableDictionary *mutableUserInfo;

- (void)setDomain:(NSString *)domain;
- (void)setCode:(NSInteger)code;

- (void)setLocalizedDescription:(NSString*)description;
- (void)setLocalizedFailureReason:(NSString*)reason;
- (void)setLocalizedRecoverySuggestion:(NSString*)recoverySuggestion;
- (void)setLocalizedRecoveryOptions:(NSArray*)recoveryOptions;
- (void)setRecoveryAttempter:(id)recoveryAttempter;

- (void)setUnderlyingError:(NSError*)error;

@end


/*!
 * @abstract A concrete protocol mimicng the informal protocol NSErrorRecoveryAttempting.
 */
@protocol CWErrorRecoveryAttempting <NSObject>

@required
/*!
 * @abstract Implement to attempt a recovery from an error noted in an application-modal dialog.
 *
 * @discussion recoveryOptionIndex can be NSNotFound on iOS where system can cancel alerts.
 */
-(BOOL)attemptRecoveryFromError:(NSError*)error optionIndex:(NSUInteger)recoveryOptionIndex;

@end
