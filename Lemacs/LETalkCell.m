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

+ (NSMutableDictionary *)URLsToWebViewHeights;
{
    NSMutableDictionary *URLsToWebViewHeights;
    return URLsToWebViewHeights ? : (URLsToWebViewHeights = [NSMutableDictionary dictionary]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    NSString *webURL = webView.request.URL.absoluteString;
//
    CGRect frame = webView.frame;
    frame.size.height = 1;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];

    [[[self class] URLsToWebViewHeights] setValue:@(fittingSize.height) forKey:webURL];
    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
}

@end
