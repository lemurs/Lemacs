//
//  LETalkListController.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//
// TODO: Make LCTalkListController a subclass of LETalkViewController, refs #26

@class LETalkViewController, UAGithubEngine;

@interface LETalkListController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) LETalkViewController *talkViewController;

- (IBAction)reloadList;
- (IBAction)resizeCells:(UIPinchGestureRecognizer *)pinch;
- (IBAction)showOptions:(UIBarButtonItem *)barButton;

@end

extern NSString * const kLETalkListTalkSize;