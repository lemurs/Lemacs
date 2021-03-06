//
//  GHComment.h
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject+LETalk.h"

@class GHIssue, GHUser;

@interface GHComment : GHManagedObject

+ (instancetype)newCommentInContext:(NSManagedObjectContext *)context;
+ (instancetype)commentNumber:(NSInteger)commentNumber context:(NSManagedObjectContext *)context;

@property (nonatomic) NSInteger commentID;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSString *body, *commentURL;
@property (nonatomic, strong) GHIssue *issue;
@property (nonatomic, strong) GHUser *user;

@end

extern NSString * const kGHCommentEntityName;

extern NSString * const kGHCommentIDGitHubKey;
extern NSString * const kGHCommentIDPropertyName;

extern NSString * const kGHCommentIssuePropertyName;

extern NSString * const kGHCommentUserGitHubKey;
extern NSString * const kGHCommentUserPropertyName;
