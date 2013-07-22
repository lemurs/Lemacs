//
//  GHComment.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHComment.h"

@implementation GHComment

+ (instancetype)commentNumber:(NSInteger)commentNumber context:(NSManagedObjectContext *)context;
{
    return [self objectWithEntityName:kGHCommentEntityName inContext:context properties:@{[self indexPropertyName] : @(commentNumber)}];
}

#pragma mark - GHManagedObject

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    static NSDictionary *GitHubKeysToPropertyNames;
    if (GitHubKeysToPropertyNames)
        return GitHubKeysToPropertyNames;

    GitHubKeysToPropertyNames = @{@"body" : @"body",
                                  @"created_at" : @"createdDate",
                                  @"html_url" : @"htmlURL",
                                  @"id" : kGHCommentIDPropertyName,
                                  @"issue_url" : @"issueURL",
                                  @"updated_at" : @"modifiedDate",
                                  @"url" : @"commentURL",
                                  @"user" : @"user"};

    return GitHubKeysToPropertyNames;
}

+ (NSString *)indexPropertyName;
{
    return kGHCommentIDPropertyName;
}



#pragma mark - API

@dynamic body, commentURL, createdDate, user;

@end

NSString * const kGHCommentEntityName = @"GHComment";
NSString * const kGHCommentIDPropertyName = @"commentID";
NSString * const kGHCommentIssuePropertyName = @"issue";
