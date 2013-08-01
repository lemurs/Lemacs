//
//  GHComment.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHComment.h"
#import "GHStore.h"

@implementation GHComment

+ (instancetype)newCommentInContext:(NSManagedObjectContext *)context;
{
    GHComment *comment = [self commentNumber:NSIntegerMax context:context];
    [[GHStore sharedStore] save];

    return comment;
}

+ (instancetype)commentNumber:(NSInteger)commentNumber context:(NSManagedObjectContext *)context;
{
    return [self objectWithEntityName:kGHCommentEntityName inContext:context properties:@{[self indexGitHubKey] : @(commentNumber)}];
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
                                  @"id" : @"commentID",
                                  @"issue_url" : @"issueURL",
                                  @"updated_at" : @"modifiedDate",
                                  @"url" : @"commentURL",
                                  @"user" : @"user"};

    return GitHubKeysToPropertyNames;
}

+ (NSString *)indexGitHubKey;
{
    return kGHCommentIDGitHubKey;
}



#pragma mark - API

@dynamic body, commentURL, createdDate, issue, user;

@end

NSString * const kGHCommentEntityName = @"GHComment";

NSString * const kGHCommentIDGitHubKey = @"id";
NSString * const kGHCommentIDPropertyName = @"commentID";

NSString * const kGHCommentIssuePropertyName = @"issue";

NSString * const kGHCommentUserGitHubKey = @"user";
NSString * const kGHCommentUserPropertyName = @"user";
