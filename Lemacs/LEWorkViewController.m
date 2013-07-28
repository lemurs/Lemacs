//
//  LEWorkViewController.m
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LEWorkViewController.h"

#import "LETalk.h"
#import "SETextView.h"

@interface LEWorkViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
- (void)configureAttributedView:(UITextView *)textView;
- (void)configurePlainTextView:(UITextView *)textView;
- (void)configureWebView:(UIWebView *)webView;

@end

@implementation LEWorkViewController

#pragma mark - UIViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated;
{
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


#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
{
    [self configureView];
}


#pragma mark - API

- (void)setTalk:(id)talk;
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
    // Commit an sync
    // else
    // Show commit screen
}

- (IBAction)togglePreview:(UISegmentedControl *)segmentedControl;
{
    BOOL showPreview = !segmentedControl.selectedSegmentIndex;
    NSLog(@"Show %@", showPreview ? @"preview" : @"editor");
}

- (void)configureView;
{
    // Update the user interface for the detail item.
    if (!self.talk || !self.selectedViewController)
        return;

    NSDictionary * const restorationIdentifierToSelectorNames = @{@"LEWebViewController" : @"configureWebView:",
                                                                  @"LECoreTextController" : @"configureAttributedView:",
                                                                  @"LERichTextController" : @"configureAttributedView:",
                                                                  @"LEPlainTextController" : @"configurePlainTextView:"};
    NSString *selectorName = restorationIdentifierToSelectorNames[self.selectedViewController.restorationIdentifier];
    if (!selectorName)
        return;

    id bodyView = [self.selectedViewController.view viewWithTag:42];

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString(selectorName) withObject:bodyView];
    #pragma clang diagnostic pop
}

- (void)configureAttributedView:(UITextView *)textView;
{
    textView.attributedText = self.talk.styledBody;
}

- (void)configurePlainTextView:(UITextView *)textView;
{
    textView.text = self.talk.body;
}

- (void)configureWebView:(UIWebView *)webView;
{
    [webView loadHTMLString:self.talk.bodyHTML baseURL:self.talk.baseURL];
}

@end
