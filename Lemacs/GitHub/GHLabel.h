//
//  GHLabel.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject.h"

@interface GHLabel : GHManagedObject
@property (nonatomic, strong) NSString *colorCode, *name, *labelURL;
@property (nonatomic, strong, readonly) UIColor *labelColor;
@end

extern NSString * const kGHLabelEntityName;
extern NSString * const kGHLabelNamePropertyName;