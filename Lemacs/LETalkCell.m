//
//  LETalkCell.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalkCell.h"
#import "SETextView.h"

@interface LETalkCell ()
@property CGFloat preferredHeight;
@end


@implementation LETalkCell

#pragma mark API

+ (CGFloat)defaultHeight;
{
    return 142.0f;
}

- (CGFloat)height;
{
    static const CGFloat kLCTalkCellMaxHeight = 342.0f; // TODO: Replace this with some empirical value
    static const CGFloat kLCTalkCellMinHeight = 42.0f;

    return MIN(MAX(self.preferredHeight, kLCTalkCellMinHeight),  kLCTalkCellMaxHeight);
}

- (void)configureCellWithTalk:(id <LETalk>)talk;
{
    self.avatarView.image = talk.avatar;
    self.timeLabel.text = talk.displayedTime;
    self.titleLabel.attributedText = talk.styledTitle;
    self.markdownView.attributedText = talk.styledBody;
}

@end
