//
//  NSError+LEPresenting.m
//  Lemacs
//
//  Created by Mike Lee on 8/6/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NSError+LEPresenting.h"

@implementation NSError (LEPresenting)

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{

}


#pragma mark - API

- (IBAction)present;
{
    if (kLEUseNarrativeLogging) {
        NSLog(@"Error! %@", self);

        // Should always exist
        NSLog(@"Description: %@", self.localizedDescription);

        // Might be useful, but I've never seen these set
        NSLog(@"Reason: %@", self.localizedFailureReason);
        NSLog(@"Options: %@", self.localizedRecoveryOptions);
        NSLog(@"Suggestion: %@", self.localizedRecoverySuggestion);
    }

    NSString *localizedTitle = NSLocalizedString(@"Uh-Oh!", @"Generic error title");
    NSString *localizedMessage = NSLocalizedString(@"Something went wrong...", @"Generic error message");
    if (!IsEmpty(self.localizedDescription))
        localizedMessage = self.localizedDescription;

    NSString *localizedCancelButtonTitle = NSLocalizedString(@"OK", @"Generic error button title");

    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:localizedCancelButtonTitle otherButtonTitles:nil];
    [errorAlert show];
}

@end
