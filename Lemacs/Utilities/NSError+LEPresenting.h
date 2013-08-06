//
//  NSError+LEPresenting.h
//  Lemacs
//
//  Created by Mike Lee on 2013-08-06.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//
//  This convenient method simply presents an alert displaying the localized error.

@interface NSError (LEPresenting) <UIAlertViewDelegate>
- (IBAction)present;
@end
