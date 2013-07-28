//
//  LEWorkViewController.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalk.h"

@interface LEWorkViewController : UITabBarController <UISplitViewControllerDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) id <LETalk> talk;

- (IBAction)save;
- (IBAction)togglePreview:(UISegmentedControl *)segmentedControl;

@end
