//
//  GHIssue.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject+LETalk.h"

@class GHComment, GHUser;

@interface GHIssue : GHManagedObject

+ (instancetype)newIssueInContext:(NSManagedObjectContext *)context;
+ (instancetype)issueNumber:(NSInteger)issueNumber context:(NSManagedObjectContext *)context;

@property (nonatomic) NSInteger commentsCount, number;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSOrderedSet *comments;
@property (nonatomic, strong) NSString *body, *issueURL, *title;
@property (nonatomic, strong) GHUser *user;

- (GHComment *)addComment;

@end

extern NSString * const kGHIssueEntityName;

extern NSString * const kGHIssueClosedGitHubKey;
extern NSString * const kGHIssueClosedPropertyName;

extern NSString * const kGHIssueCommentsGitHubKey;
extern NSString * const kGHIssueCommentsPropertyName;

extern NSString * const kGHIssueNumberGitHubKey;
extern NSString * const kGHIssueNumberPropertyName;
