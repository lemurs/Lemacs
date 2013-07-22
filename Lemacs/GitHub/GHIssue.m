//
//  GHIssue.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHIssue.h"

@implementation GHIssue

+ (instancetype)issueNumber:(NSInteger)issueNumber context:(NSManagedObjectContext *)context;
{
    return [self objectWithEntityName:kGHIssueEntityName inContext:context properties:@{[self indexPropertyName] : @(issueNumber)}];
}


#pragma mark NSObject (KeyValueCoding)

- (BOOL)validateValue:(id *)value forKey:(NSString *)key error:(NSError **)error;    // KVC
{
    if ([key isEqualToString:kGHIssueClosedPropertyName]) {
        if ([*value isKindOfClass:[NSNumber class]])
            return YES;
        else if (![*value isKindOfClass:[NSString class]])
            return NO;
        else if ([*value isEqualToString:@"closed"])
            *value = [NSNumber numberWithBool:YES];
        else
            *value = [NSNumber numberWithBool:NO];
    } else
        return [super validateValue:value forKey:key error:error];

    return YES;
}


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
                                  @"number" : kGHIssueNumberPropertyName,
                                  @"pull_request" : @"pullRequest",
                                  @"state" : kGHIssueClosedPropertyName,
                                  @"title" : @"title",
                                  @"updated_at" : @"modifiedDate",
                                  @"url" : @"issueURL",
                                  @"user" : @"user"};

    return GitHubKeysToPropertyNames;
}

+ (NSString *)indexPropertyName;
{
    return kGHIssueNumberPropertyName;
}


#pragma mark - API

@dynamic body, comments, commentsCount, createdDate, issueURL, issueNumber, user;

@end

NSString * const kGHIssueEntityName = @"GHIssue";
NSString * const kGHIssueClosedPropertyName = @"closed";
NSString * const kGHIssueNumberPropertyName = @"issueNumber";
