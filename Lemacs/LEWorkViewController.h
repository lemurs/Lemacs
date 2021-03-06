//
//  LEWorkViewController.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalk.h"

@interface LEWorkViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *topicField;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) id <LETalk> talk;

- (IBAction)cancel;
- (IBAction)delete;
- (IBAction)reply;
- (IBAction)save;
- (IBAction)togglePreview:(UISegmentedControl *)segmentedControl;

@end
