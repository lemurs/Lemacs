//
//  GHComment.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHComment.h"

@implementation GHComment

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

@end

NSString * const kGHCommentEntityName = @"GHComment";
