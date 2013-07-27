//
//  NSAttributedStringMarkdownParser+GHMarkdown.m
//  Lemacs
//
//  Created by Mike Lee on 7/27/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NSAttributedStringMarkdownParser+GHMarkdown.h"
#import "UIFont+GHMarkdown.h"

@implementation NSAttributedStringMarkdownParser (GHMarkdown)

+ (instancetype)sharedParser;
{
    static NSAttributedStringMarkdownParser *sharedParser;
    if (sharedParser)
        return sharedParser;

    sharedParser = [[NSAttributedStringMarkdownParser alloc] init];
    sharedParser.paragraphFont = [UIFont markdownParagraphFont];
    [sharedParser setFont:[UIFont markdownHeader1Font] forHeader:NSAttributedStringMarkdownParserHeader1];
    [sharedParser setFont:[UIFont markdownHeader2Font] forHeader:NSAttributedStringMarkdownParserHeader2];
    [sharedParser setFont:[UIFont markdownHeader3Font] forHeader:NSAttributedStringMarkdownParserHeader3];
    [sharedParser setFont:[UIFont markdownHeader4Font] forHeader:NSAttributedStringMarkdownParserHeader4];
    [sharedParser setFont:[UIFont markdownHeader5Font] forHeader:NSAttributedStringMarkdownParserHeader5];
    [sharedParser setFont:[UIFont markdownHeader6Font] forHeader:NSAttributedStringMarkdownParserHeader6];

    return sharedParser;
}

@end
