//
//  GHIssue.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHIssue.h"
#import "NSAttributedStringMarkdownParser+GHMarkdown.h"

@implementation GHIssue

+ (instancetype)issueNumber:(NSInteger)issueNumber context:(NSManagedObjectContext *)context;
{
    return [self objectWithEntityName:kGHIssueEntityName inContext:context properties:@{[self indexGitHubKey] : @(issueNumber)}];
}


#pragma mark NSObject (KeyValueCoding)

- (BOOL)validateValue:(id *)value forKey:(NSString *)key error:(NSError **)error;    // KVC
{
    if ([key isEqualToString:kGHIssueClosedPropertyName]) {
        if ([*value isKindOfClass:[NSNumber class]])
            return YES;
        else if (!*value)
            *value = [NSNumber numberWithBool:NO];
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
                                  @"number" : @"number",
                                  @"pull_request" : @"pullRequest",
                                  @"state" : @"closed",
                                  @"title" : @"title",
                                  @"updated_at" : @"modifiedDate",
                                  @"url" : @"issueURL",
                                  @"user" : @"user"};

    return GitHubKeysToPropertyNames;
}

+ (NSString *)indexGitHubKey;
{
    return kGHIssueNumberGitHubKey;
}


#pragma mark - GHTalk

- (NSAttributedString *)styledBody;
{// FIXME: Appending the title here is a nice hack, but then it disappears during editing.
    NSString *fullBody = IsEmpty(self.title) ? @"" : [[@"# " stringByAppendingString:self.title] stringByAppendingString:@"\n\n"];
    fullBody = [fullBody stringByAppendingString:NonNil(self.body, @"")];
    return [[NSAttributedStringMarkdownParser sharedParser] attributedStringFromMarkdownString:fullBody];
}


#pragma mark - API

@dynamic body, comments, commentsCount, createdDate, issueURL, number, title, user;

@end

NSString * const kGHIssueEntityName = @"GHIssue";

NSString * const kGHIssueClosedGitHubKey = @"state";
NSString * const kGHIssueClosedPropertyName = @"closed";
NSString * const kGHIssueNumberGitHubKey = @"number";
NSString * const kGHIssueNumberPropertyName = @"number";
