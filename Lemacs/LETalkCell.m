//
//  LETalkCell.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalkCell.h"
#import "SETextView.h"

@implementation LETalkCell

#pragma mark API

- (void)configureCellWithTalk:(id <LETalk>)talk;
{
    self.avatarView.image = talk.avatar;
    self.timeLabel.text = talk.displayedTime;
    self.titleLabel.attributedText = talk.styledTitle;
    self.markdownView.attributedText = talk.styledBody;
}

@end
