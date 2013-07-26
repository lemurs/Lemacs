//
//  LETalkCell.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalkCell.h"

@implementation LETalkCell

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    NSString *webURL = webView.request.URL.absoluteString;

    CGRect frame = webView.frame;
    frame.size.height = 1;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];

    [[[self class] URLsToWebViewHeights] setValue:@(fittingSize.height) forKey:webURL];
    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
}


#pragma mark API

+ (NSMutableDictionary *)URLsToWebViewHeights;
{
    NSMutableDictionary *URLsToWebViewHeights;
    return URLsToWebViewHeights ? : (URLsToWebViewHeights = [NSMutableDictionary dictionary]);
}

- (void)configureCellWithTalk:(id <LETalk>)talk;
{
    self.avatarView.image = talk.avatar;
    self.timeLabel.text = talk.displayedTime;
    self.titleLabel.attributedText = talk.styledTitle;
    [self.webView loadHTMLString:talk.bodyHTML baseURL:talk.baseURL];
}

@end
