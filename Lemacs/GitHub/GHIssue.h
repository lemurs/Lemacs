//
//  GHIssue.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject+LETalk.h"

@class GHUser;

@interface GHIssue : GHManagedObject

+ (instancetype)issueNumber:(NSInteger)issueNumber context:(NSManagedObjectContext *)context;

@property (nonatomic) NSInteger commentsCount, issueNumber;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) NSOrderedSet *comments;
@property (nonatomic, strong) NSString *body, *issueURL;
@property (nonatomic, strong) GHUser *user;

@end

extern NSString * const kGHIssueEntityName;
extern NSString * const kGHIssueClosedPropertyName;
extern NSString * const kGHIssueNumberPropertyName;
