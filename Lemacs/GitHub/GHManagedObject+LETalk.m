//
//  GHManagedObject+LETalk.m
//  Lemacs
//
//  Created by Mike Lee on 7/22/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject+LETalk.h"
#import "GHComment.h"
#import "GHUser.h"
#import "NSAttributedStringMarkdownParser+GHMarkdown.h"
#import "SundownWrapper.h"

@implementation GHManagedObject (LETalk)

#pragma mark - LETalk

- (UIImage *)avatar;
{
    if ([self respondsToSelector:@selector(user)])
        return [self valueForKeyPath:@"user.avatar"];
    else
        return nil;
}

- (NSURL *)baseURL;
{
    return [NSURL URLWithString:[[self class] GitHubKeysToPropertyNames][@"url"]];
}

- (NSString *)bodyHTML;
{
    if ([self respondsToSelector:@selector(body)])
        return [SundownWrapper convertMarkdownString:self.plainBody];
    else
        return nil;
}

- (NSString *)displayedTime;
{
    if (![self respondsToSelector:@selector(createdDate)])
        return nil;

    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EdMMM" options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];

    return [dateFormatter stringFromDate:[self valueForKeyPath:@"createdDate"]];
}

- (NSString *)plainBody;
{
    return [self currentValueForKey:kLETalkBodyKey];
}

- (NSAttributedString *)styledBody;
{
    return [[NSAttributedStringMarkdownParser sharedParser] attributedStringFromMarkdownString:self.plainBody];
}

- (NSAttributedString *)styledTitle;
{
    if (![self respondsToSelector:@selector(user)])
        return nil;

    GHUser *user = [self valueForKey:@"user"];

    NSDictionary *boldBlackStyle = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:10.0f],
                                     NSForegroundColorAttributeName : [UIColor blackColor]};
    NSDictionary *lightGrayStyle = @{NSFontAttributeName : [UIFont systemFontOfSize:10.0f],
                                     NSForegroundColorAttributeName : [UIColor lightGrayColor]};

    static NSString * const emptyString = @" ";
    static NSString * const separatorString = @" ";

    NSMutableAttributedString *styledTitle = [[NSMutableAttributedString alloc] initWithString:[NonNil(user.displayName, emptyString) stringByAppendingString:separatorString] attributes:boldBlackStyle];

    [styledTitle appendAttributedString:[[NSAttributedString alloc] initWithString:NonNil(user.userName, emptyString) attributes:lightGrayStyle]];

    return styledTitle;
}


@end
