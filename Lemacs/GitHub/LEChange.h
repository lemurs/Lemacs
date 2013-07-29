//
//  LEChange.h
//  Lemacs
//
//  Created by Mike Lee on 7/29/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class GHManagedObject;

@interface LEChange : NSManagedObject
@property (nonatomic, weak) GHManagedObject *original;
@property (nonatomic, strong) NSString *keyName, *propertyName, *stringValue;
@end

extern NSString * const kLEChangeEntityName;