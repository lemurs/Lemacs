//
//  GHManagedObject.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class LEChange;


@interface GHManagedObject : NSManagedObject

+ (instancetype)objectWithEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context properties:(NSDictionary *)properties;

+ (NSDictionary *)GitHubKeysToPropertyNames;
+ (NSString *)indexGitHubKey;

@property (nonatomic, readonly) BOOL needsUpdating;
@property (nonatomic, strong) NSDate *lastUpdated;

@end


@interface GHManagedObject (Change)

@property (nonatomic, readonly) BOOL hasChanges;
@property (nonatomic, strong) NSSet *changes;

- (id)currentValueForKey:(NSString *)propertyName;
- (LEChange *)changeForPropertyNamed:(NSString *)propertyName;

- (id)changeValueForGitHubKeyNamed:(NSString *)key;
- (void)setChangeValue:(id)changeValue forGitHubKeyNamed:(NSString *)key;

- (id)changeValueForPropertyNamed:(NSString *)propertyName;
- (void)setChangeValue:(id)changeValue forPropertyNamed:(NSString *)propertyName;

@end


extern const NSTimeInterval kGHStoreUpdateLimit;

extern NSString * const kGHCreatedDatePropertyName;
extern NSString * const kGHUpdatedDatePropertyName;
extern NSString * const kGHModifiedDatePropertyName;
