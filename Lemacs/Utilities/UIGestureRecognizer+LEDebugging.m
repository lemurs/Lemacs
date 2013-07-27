//
//  UIGestureRecognizer+LEDebugging.m
//  Lemacs
//
//  Created by Mike Lee on 7/27/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "UIGestureRecognizer+LEDebugging.h"

@implementation UIGestureRecognizer (LEDebugging)

- (NSString *)stateName;
{
    switch (self.state) {
        case UIGestureRecognizerStatePossible:
            return @"Possible";

        case UIGestureRecognizerStateBegan:
            return @"Began";

        case UIGestureRecognizerStateChanged:
            return @"Changed";

        case UIGestureRecognizerStateEnded:
            return @"Ended";

        case UIGestureRecognizerStateCancelled:
            return @"Cancelled";

        case UIGestureRecognizerStateFailed:
            return @"Failed";

        default:
            break;
    }
}

@end
