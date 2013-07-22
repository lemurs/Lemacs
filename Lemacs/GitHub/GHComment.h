//
//  GHComment.h
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject+LETalk.h"

@class GHUser;

@interface GHComment : GHManagedObject
+ (instancetype)commentNumber:(NSInteger)commentNumber context:(NSManagedObjectContext *)context;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSString *body, *commentURL;
@property (nonatomic, strong) GHUser *user;
@end

extern NSString * const kGHCommentEntityName;
extern NSString * const kGHCommentIDPropertyName;
extern NSString * const kGHCommentIssuePropertyName;