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
#import "UIFont+GHMarkdown.h"

@interface LEWorkViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end

@implementation LEWorkViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self configureView];
    // TODO: Select the preview unless there are edits
}

- (void)viewDidAppear:(BOOL)animated;
{
    // FIXME: There is some kind of fight happening for firstResponder where it is taken from the text view after viewWillAppear: We can win this fight here, but it does make the UI blink, so we should try to figure out why it's happening and fix it.
    [self.textView becomeFirstResponder];
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
    if (!self.textView)
        return;

    self.textView.editable = editing;
    self.textView.font = [UIFont markdownParagraphFont]; // To clear style

    if (editing)
        self.textView.text = self.talk.plainBody;
    else
        self.textView.attributedText = self.talk.styledBody;

    super.editing = editing;
    [self.textView becomeFirstResponder];
}

- (void)setTalk:(id <LETalk>)talk;
{
    if (_talk == talk)
        return;

    _talk = talk;
        
    [self configureView];
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
    self.editing = IsEmpty([(NSObject *)self.talk valueForKey:kLETalkBodyKey]) || ((id <LETalk>)self.talk).hasChanges;
    self.segmentedControl.selectedSegmentIndex = self.editing ? 1 : 0;
}

@end
