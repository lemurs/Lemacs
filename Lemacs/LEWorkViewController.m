//
//  LEWorkViewController.m
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LEWorkViewController.h"

#import "GHManagedObject+LETalk.h"
#import "GHStore.h"
#import "SETextView.h"

@interface LEWorkViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end

@implementation LEWorkViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    [self configureView];
    // TODO: Select the preview unless there are edits
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController;
{
    barButtonItem.title = NSLocalizedString(@"Talk", @"Talk");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), textView.text);
}

- (void)textViewDidEndEditing:(UITextView *)textView;
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), textView.text);

    [[GHStore sharedStore] save];
}

- (void)textViewDidChange:(UITextView *)textView;
{
    GHManagedObject *editedObject = (GHManagedObject *)self.talk;
    assert([editedObject isKindOfClass:[GHManagedObject class]]);

    [editedObject setChangeValue:textView.text forPropertyNamed:kLETalkBodyKey];
}


#pragma mark - API

- (void)setEditing:(BOOL)editing;
{
    self.textView.editable = editing;
    if (editing)
        self.textView.text = self.talk.plainBody;
    else
        self.textView.attributedText = self.talk.styledBody;

    [self.textView becomeFirstResponder];
    super.editing = editing;
}

- (void)setTalk:(id <LETalk>)talk;
{
    if (_talk != talk) {
        _talk = talk;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (IBAction)save;
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // If new
    // Commit and sync
    // else
    // Show commit screen
}

- (IBAction)togglePreview:(UISegmentedControl *)segmentedControl;
{
    self.editing = segmentedControl.selectedSegmentIndex;
}

- (void)configureView;
{
    if (!self.talk)
        return; // This should only happen while the controller is still being set up

    // Default to editing mode if this is an uncommited talk
    // TODO: Default to editing mode if talk has unsaved changes.
    self.editing = IsEmpty(self.talk.baseURL);
}

@end
