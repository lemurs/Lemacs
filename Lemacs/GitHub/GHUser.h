//
//  GHUser.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject.h"

@interface GHUser : GHManagedObject

+ (instancetype)userNamed:(NSString *)userName context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString *avatarURL, *fullName, *userName;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) UIImage *avatar;

@end

extern NSString * const kGHUserEntityName;

extern NSString * const kGHUserHandleGitHubKey;
extern NSString * const kGHUserHandlePropertyName;
