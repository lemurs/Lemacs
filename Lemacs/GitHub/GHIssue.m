//
//  GHIssue.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHIssue.h"

@implementation GHIssue

#pragma mark - GHManagedObject

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    static NSDictionary *GitHubKeysToPropertyNames;
    if (GitHubKeysToPropertyNames)
        return GitHubKeysToPropertyNames;

    GitHubKeysToPropertyNames = @{@"assignee" : @"assignee",
                                  @"body" : @"body",
                                  @"closed_at" : @"closedDate",
                                  @"comments" : @"commentsCount",
                                  @"comments_url" : @"commentsURL",
                                  @"created_at" : @"createdDate",
                                  @"events_url" : @"eventsURL",
                                  @"html_url" : @"htmlURL",
                                  @"id" : @"issueID",
                                  @"labels" : @"labels",
                                  @"labels_url" : @"labelsURL",
                                  @"milestone" : @"milestone",
                                  @"number" : @"number",
                                  @"pull_request" : @"pullRequest",
                                  @"state" : @"closed",
                                  @"title" : @"title",
                                  @"updated_at" : @"modifiedDate",
                                  @"url" : @"issueURL",
                                  @"user" : @"user"};

    return GitHubKeysToPropertyNames;
}


#pragma mark - API

@dynamic body, comments, commentsCount, number;

@end

NSString * const kGHIssueEntityName = @"GHIssue";
