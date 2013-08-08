//
//  LEListViewController.m
//  Lemacs
//
//  Created by Mike Lee on 8/8/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LEListViewController.h"
#import "GHLabel.h"
#import "GHStore.h"
#import "NSError+LEPresenting.h"
#import "CIColor+HexCodes.h"

@interface LEListViewController ()

+ (NSString *)sortKey;
+ (NSString *)sortOrderKey;

@property (nonatomic) BOOL reverseSort;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation LEListViewController

+ (void)initialize;
{
    if ([[self class] sortOrderKey])
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{[[self class] sortOrderKey] : @(NO)}];
}


#pragma mark - UIViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.reverseSort = [[NSUserDefaults standardUserDefaults] integerForKey:[[self class] sortOrderKey]];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self reloadList];
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@", NSStringFromSelector(_cmd));

    // TODO: Dispose of any resources that can be recreated.
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.fetchResults.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchResults.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSManagedObjectContext *context = self.fetchResults.managedObjectContext;

    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [context deleteObject:[self.fetchResults objectAtIndexPath:indexPath]];
            break;

        default:
            return;
    }

    [[GHStore sharedStore] save];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return NO;
}


#pragma mark - API

+ (NSString *)entityName;
{
    return nil; // Override
}

+ (NSString *)sortKey;
{
    return nil; // Override
}

+ (NSString *)sortOrderKey;
{
    return [[[self class] entityName] stringByAppendingString:@"-SortOrder"];
}

@synthesize fetchResults = _fetchResults, managedObjectContext = _managedObjectContext;

- (NSFetchedResultsController *)fetchResults;
{
    if (_fetchResults)
        return _fetchResults;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:[[self class] entityName] inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:[[self class] sortKey] ascending:self.reverseSort]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    fetchResults.delegate = self;

    _fetchResults = fetchResults;

    return fetchResults;
}

- (NSManagedObjectContext *)managedObjectContext;
{// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    if (_managedObjectContext)
        return _managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [[GHStore sharedStore] persistentStoreCoordinator];
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }

    return _managedObjectContext;
}

- (void)setReverseSort:(BOOL)reverseSort;
{
    if (_reverseSort == reverseSort)
        return;

    _reverseSort = reverseSort;
    [self reloadList];
    [[NSUserDefaults standardUserDefaults] boolForKey:[[self class] sortOrderKey]];
}

- (IBAction)reloadList;
{
    // If we switch from [^|v] to [v|^] change self.reverseSort to !self.reverseSort
    self.fetchResults.fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:[[self class] sortKey] ascending:self.reverseSort]];

    NSError *fetchError;
    if (![self.fetchResults performFetch:&fetchError]) {
        [fetchError present];
        return;
    }

    if (self.fetchResults.sections.count)
        [self.tableView reloadData];
    else
        [[GHStore sharedStore] loadIssues:YES];

    [self.refreshControl endRefreshing];
}

- (IBAction)sortList:(UISegmentedControl *)sortControl;
{
    if (self.reverseSort != sortControl.selectedSegmentIndex)
        self.reverseSort = sortControl.selectedSegmentIndex;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    assert(NO); // Override
}

@end


@implementation LEAccountListController

+ (NSString *)entityName;
{
    return @"GHUser";
}

+ (NSString *)sortKey;
{
    return @"fullName";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    cell.textLabel.text = [[self.fetchResults objectAtIndexPath:indexPath] valueForKey:@"fullName"];
    cell.detailTextLabel.text = [[self.fetchResults objectAtIndexPath:indexPath] valueForKey:@"userName"];
}

@end


@implementation LEDocumentListController

+ (NSString *)entityName;
{
    return @"LEDocument";
}

+ (NSString *)sortKey;
{
    return @"whatever";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    cell.textLabel.text = @"Document name";
}

@end


@implementation LELabelListController

+ (NSString *)entityName;
{
    return @"GHLabel";
}

+ (NSString *)sortKey;
{
    return @"name";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    GHLabel *label = [self.fetchResults objectAtIndexPath:indexPath];
    assert([label isKindOfClass:[GHLabel class]]);

    NSLog(@"%@", [CIColor colorWithHexCode:label.colorCode]);
    NSLog(@"%@", [[CIImage imageWithColor:[CIColor colorWithHexCode:label.colorCode]] imageByCroppingToRect:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)]);
    NSLog(@"%@", [UIImage imageWithCIImage:[[CIImage imageWithColor:[CIColor colorWithHexCode:label.colorCode]] imageByCroppingToRect:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)]]);
    cell.imageView.image = [UIImage imageWithCIImage:[[CIImage imageWithColor:[CIColor colorWithHexCode:label.colorCode]] imageByCroppingToRect:CGRectMake(0.0f, 0.0f, 42.0f, 42.0f)]];
    cell.textLabel.text = [[self.fetchResults objectAtIndexPath:indexPath] valueForKey:@"name"];
}

@end


@implementation LERepositoryListController

+ (NSString *)entityName;
{
    return @"GHRepo";
}


+ (NSString *)sortKey;
{
    return @"name";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    cell.textLabel.text = @"Repo Name";
}

@end


@implementation LESnippetListController

+ (NSString *)entityName;
{
    return @"GHGist";
}

+ (NSString *)sortKey;
{
    return @"name";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    cell.textLabel.text = @"Gist name / content";
}

@end

