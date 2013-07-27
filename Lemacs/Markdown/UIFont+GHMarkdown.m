//
//  UIFont+GHMarkdown.m
//  Lemacs
//
//  Created by Mike Lee on 7/27/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "UIFont+GHMarkdown.h"

@implementation UIFont (GHMarkdown)

+ (instancetype)markdownParagraphFont;
{
    return [self systemFontOfSize:10.0f];
}

+ (instancetype)markdownHeader1Font;
{
    return [self boldSystemFontOfSize:12.0f];
}

+ (instancetype)markdownHeader2Font;
{
    return [self italicSystemFontOfSize:12.0f];
}

+ (instancetype)markdownHeader3Font;
{
    return [self boldSystemFontOfSize:11.0f];
}

+ (instancetype)markdownHeader4Font;
{
    return [self italicSystemFontOfSize:11.0f];
}

+ (instancetype)markdownHeader5Font;
{
    return [self boldSystemFontOfSize:10.0f];
}

+ (instancetype)markdownHeader6Font;
{
    return [self italicSystemFontOfSize:10.0f];
}

@end
