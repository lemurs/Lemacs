//
//  GHComment.h
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject.h"

@class GHUser;

@interface GHComment : GHManagedObject
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) GHUser *user;
@end

extern NSString * const kGHCommentEntityName;
extern NSString * const kGHCommentIssuePropertyName;