//
//  GHIssue.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject.h"

@interface GHIssue : GHManagedObject
@property (nonatomic) NSInteger commentsCount, number;
@property (nonatomic, strong) NSOrderedSet *comments;
@property (nonatomic, strong) NSString *body;
@end

extern NSString * const kGHIssueEntityName;