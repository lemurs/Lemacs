//
//  GHManagedObject.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@interface GHManagedObject : NSManagedObject

+ (instancetype)objectWithEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context properties:(NSDictionary *)properties;

+ (NSDictionary *)GitHubKeysToPropertyNames;
+ (NSString *)indexPropertyName;

@property (nonatomic, readonly) BOOL needsUpdating;
@property (nonatomic, strong) NSDate *lastUpdated;

@end

extern const NSTimeInterval kGHStoreUpdateLimit;

extern NSString * const kGHCreatedDatePropertyName;
extern NSString * const kGHUpdatedDatePropertyName;
extern NSString * const kGHModifiedDatePropertyName;
