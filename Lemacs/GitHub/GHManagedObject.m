//
//  GHManagedObject.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject.h"

#import "GHStore.h"
#import "LEChange.h"
#import "NSDate+GitHub.h"
#import "NSError+LEPresenting.h"


@interface GHManagedObject ()
- (void)setUpRelationship:(NSRelationshipDescription *)relationship withValue:(id)value forKey:(NSString *)key;
- (void)setUpToManyRelationship:(NSRelationshipDescription *)relationship withValue:(NSArray *)values forKey:(NSString *)key;
- (BOOL)validateRelationship:(NSRelationshipDescription *)relationship withValue:(id *)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)validateToManyRelationship:(NSRelationshipDescription *)relationship withValue:(NSArray **)values forKey:(NSString *)key error:(NSError **)error;;
@end


@implementation GHManagedObject

+ (instancetype)objectWithEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context properties:(NSDictionary *)properties;
{
    // Convert GitHub key-value pair into Core Data property-value pair
    NSString *indexGitHubKey = [NSClassFromString(entityName) indexGitHubKey];
    assert(indexGitHubKey); // GHManagedObject is abstract

    NSString *indexPropertyName = [[NSClassFromString(entityName) GitHubKeysToPropertyNames] valueForKey:indexGitHubKey];
    id indexPropertyValue = properties[indexGitHubKey];

    if (!indexPropertyValue) { // Maybe this needs to be a property name?
        indexPropertyValue = properties[indexPropertyName];
    }

    // Set up a fetch request to see if any objects match that property-value
    NSPredicate *predicate = indexPropertyValue ? [NSPredicate predicateWithFormat:@"%K == %@" argumentArray:@[indexPropertyName, indexPropertyValue]] : nil;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = predicate;

    NSArray *fetchResults;
    NSError *fetchError;
    if (!(fetchResults = [context executeFetchRequest:fetchRequest error:&fetchError]))
        [fetchError present];

    id managedObject = fetchResults.lastObject;
    if (managedObject) // Existing object found!
        return managedObject;

    // Create a new object
    managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    [managedObject setValue:indexPropertyValue forKey:indexPropertyName];
    [managedObject setValue:[NSDate distantPast] forKey:kGHUpdatedDatePropertyName];

    if ([managedObject respondsToSelector:@selector(setCreatedDate:)])
        [managedObject setValue:[NSDate date] forKey:kGHCreatedDatePropertyName];

    if ([managedObject respondsToSelector:@selector(setModifiedDate:)])
        [managedObject setValue:[NSDate date] forKey:kGHModifiedDatePropertyName];

    return managedObject;
}


#pragma mark NSObject (KeyValueCoding)

- (void)setValue:(id)value forKey:(NSString *)key;
{
    if (IsEmpty(key) || IsEmpty(value))
        return; // We may wish to treat this differently in the future to for example delete a previously set value.

    if ([[self valueForKey:key] isEqual:value])
        return;

    NSDictionary *properties = self.entity.propertiesByName;
    NSPropertyDescription *property = properties[key];
    if ([property isKindOfClass:[NSRelationshipDescription class]])
        return [self setUpRelationship:(NSRelationshipDescription *)property withValue:value forKey:key];

    NSError *validationError;
    if ([self validateValue:&value forKey:key error:&validationError])
        [super setValue:value forKey:key];
    else
        [validationError present];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
{
    key = [[self class] GitHubKeysToPropertyNames][key];
    if (key)
        [self setValue:value forKey:key];
    else
        [super setValue:value forUndefinedKey:key];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
{
    NSDate *modifiedDate = keyedValues[kGHModifiedDatePropertyName];
    if (!IsEmpty(modifiedDate)) {
        assert ([self respondsToSelector:@selector(modifiedDate)]);
        NSDate *currentValue = [self valueForKey:kGHModifiedDatePropertyName];

        NSError *validationError;
        if (![self validateValue:&modifiedDate forKey:kGHModifiedDatePropertyName error:&validationError])
            [validationError present];

        if ([currentValue isEqualToDate:modifiedDate])
            return; // No changes expected
    }

    NSDictionary *GitHubKeysToPropertyNames = [[self class] GitHubKeysToPropertyNames];
    GHManagedObject *object = self;
    [keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [object setValue:value forKey:GitHubKeysToPropertyNames[key]];
    }];
}

- (BOOL)validateValue:(id *)value forKey:(NSString *)key error:(NSError **)error;    // KVC
{
//    static NSString * const WhatThisDoes = @"This method is responsible for two things: coercing the value into an appropriate type for the object, and validating it according to the object’s rules.";
//    NSLog(@"%@ %@ : %@", NSStringFromSelector(_cmd), key, *value);

    NSDictionary *properties = self.entity.propertiesByName;
    NSPropertyDescription *property = properties[key];
    if ([property isKindOfClass:[NSRelationshipDescription class]])
        return [self validateRelationship:(NSRelationshipDescription *)property withValue:value forKey:key error:error];

    assert([property isKindOfClass:[NSAttributeDescription class]]);
    NSAttributeDescription *attribute = (NSAttributeDescription *)property;

    switch (attribute.attributeType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            if ([*value isKindOfClass:[NSNumber class]])
                return YES;
            else if ([*value isKindOfClass:[NSString class]])
                *value = [NSNumber numberWithInteger:[*value integerValue]];
            else if (!*value)
                *value = [NSNumber numberWithInteger:0];
            else
                return NO; // TODO: Set error

            return YES;

        case NSDoubleAttributeType:
            if ([*value isKindOfClass:[NSNumber class]])
                return YES;
            else if ([*value isKindOfClass:[NSString class]])
                *value = [NSNumber numberWithDouble:[*value doubleValue]];
            else if (!*value)
                *value = [NSNumber numberWithDouble:0.0f];
            else
                return NO;

            return YES;

        case NSFloatAttributeType:
            if ([*value isKindOfClass:[NSNumber class]])
                return YES;
            else if ([*value isKindOfClass:[NSString class]])
                *value = [NSNumber numberWithFloat:[*value floatValue]];
            else if (!*value)
                *value = [NSNumber numberWithFloat:0.0f];
            else
                return NO;

            return YES;

        case NSDecimalAttributeType:
            if ([*value isKindOfClass:[NSDecimalNumber class]])
                return YES;
            else if ([*value isKindOfClass:[NSString class]])
                *value = [NSDecimalNumber decimalNumberWithString:*value];
            else if (!*value)
                *value = [NSDecimalNumber decimalNumberWithString:@"0"];
            else
                return NO;

            return YES;

        case NSStringAttributeType:
            break;

        case NSBooleanAttributeType:
            if ([*value isKindOfClass:[NSNumber class]])
                return YES;
            else if ([*value isKindOfClass:[NSString class]])
                *value = [NSNumber numberWithBool:[*value boolValue]];
            else if (!*value)
                *value = [NSNumber numberWithBool:NO];
            else
                return NO;

            return YES;

        case NSDateAttributeType:
            if ([*value isKindOfClass:[NSDate class]])
                return YES;
            else if ([*value isKindOfClass:[NSString class]])
                *value = [NSDate dateWithGitHubDateString:*value];
            else if (!*value)
                *value = [key isEqualToString:kGHCreatedDatePropertyName] ? [NSDate distantPast] : nil;
            else
                return [super validateValue:value forKey:key error:error];

            return YES;

        case NSBinaryDataAttributeType:
            if ([*value isKindOfClass:[NSData class]])
                return YES;
            else if (!*value)
                *value = [NSData data];
            else
                return NO;

            return YES;

        default:
            break;
    }

    return [super validateValue:value forKey:key error:error];
}


#pragma mark - API

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    return nil; // Override
}

+ (NSString *)indexGitHubKey;
{
    return nil; // Override
}


@dynamic lastUpdated;

- (BOOL)needsUpdating;
{
    return -[self.lastUpdated timeIntervalSinceNow] > kGHStoreUpdateLimit;
}

- (NSDictionary *)dictionaryWithValuesForGitHubKeys:(NSArray *)keys;
{
    __block NSMutableDictionary *GitHubKeysToCurrentValues = [NSMutableDictionary dictionaryWithCapacity:keys.count];
    GHManagedObject * __weak currentObject = self;
    [keys enumerateObjectsUsingBlock:^(NSString *GitHubKey, NSUInteger uselessIndex, BOOL *stop) {
        if ([GitHubKey isEqualToString:[[currentObject class] indexGitHubKey]])
            return;

        NSString *propertyName = [[self class] GitHubKeysToPropertyNames][GitHubKey];
        id propertyValue = [currentObject currentValueForKey:propertyName];
        [GitHubKeysToCurrentValues setValue:propertyValue forKey:GitHubKey];
    }];

    return [GitHubKeysToCurrentValues copy];
}

- (void)setUpRelationship:(NSRelationshipDescription *)relationship withValue:(id)value forKey:(NSString *)key;
{
    if (relationship.isToMany)
        return [self setUpToManyRelationship:relationship withValue:(NSArray *)value forKey:key];

    if ([value isKindOfClass:[GHManagedObject class]])
        return [super setValue:value forKey:key];

    assert([value isKindOfClass:[NSDictionary class]]);

    GHManagedObject *object = [GHManagedObject objectWithEntityName:relationship.destinationEntity.name inContext:self.managedObjectContext properties:value];
    if (object.needsUpdating)
        [object setValuesForKeysWithDictionary:value];

    [super setValue:object forKey:key];
}

- (void)setUpToManyRelationship:(NSRelationshipDescription *)relationship withValue:(NSArray *)values forKey:(NSString *)key;
{
    if (![values.lastObject isKindOfClass:[NSDictionary class]]) {
        id value = relationship.isOrdered ? [NSOrderedSet orderedSetWithArray:values] : [NSSet setWithArray:values];
        return [super setValue:value forKey:key];
    }

    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:values.count];

    [values enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
        GHManagedObject *object = [GHManagedObject objectWithEntityName:relationship.destinationEntity.name  inContext:self.managedObjectContext properties:dictionary];
        if (object.needsUpdating)
            [object setValuesForKeysWithDictionary:(NSDictionary *)dictionary];

        [objects addObject:object];
    }];

    id value = relationship.isOrdered ? [NSOrderedSet orderedSetWithArray:objects] : [NSSet setWithArray:objects];
    [super setValue:value forKey:key];
}

- (BOOL)validateRelationship:(NSRelationshipDescription *)relationship withValue:(id *)value forKey:(NSString *)key error:(NSError **)error;
{
    if (relationship.isToMany)
        return [self validateToManyRelationship:relationship withValue:value forKey:key error:error];

    if ([*value isKindOfClass:[GHManagedObject class]])
        return [super validateValue:value forKey:key error:error];

    if ([key isEqualToString:@"pullRequest"] || [key isEqualToString:@"milestone"] || [key isEqualToString:@"assignee"]) {
        *value = nil;
        return YES;
    }

    if (!*value)
        return YES;

    if (![*value isKindOfClass:[NSDictionary class]])
        return NO; // TODO: Set error

    NSDictionary *properties = *value;
    *value = [GHManagedObject objectWithEntityName:relationship.destinationEntity.name inContext:self.managedObjectContext properties:properties];

    return YES;
}

- (BOOL)validateToManyRelationship:(NSRelationshipDescription *)relationship withValue:(NSArray **)values forKey:(NSString *)key error:(NSError **)error;
{
    if (relationship.isOrdered && [*values isKindOfClass:[NSOrderedSet class]])
        return YES;
    else if (!relationship.isOrdered && [*values isKindOfClass:[NSSet class]])
        return YES;
    else if (![*values isKindOfClass:[NSArray class]])
        return NO; // TODO: Set error

    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[*values count]];
    [*values enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
        if (![dictionary isKindOfClass:[NSDictionary class]])
            *stop = YES;

        GHManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:relationship.destinationEntity.name inManagedObjectContext:self.managedObjectContext];
        [object setValuesForKeysWithDictionary:(NSDictionary *)dictionary];
        [objects addObject:object];
    }];

    *values = objects;

    return YES;
}

@end


@implementation GHManagedObject (Change)

@dynamic changes;

- (BOOL)hasChanges;
{
    return self.changes.count;
}

- (id)currentValueForKey:(NSString *)propertyName;
{
    return [self changeValueForPropertyNamed:propertyName] ? : [self valueForKey:propertyName];
}

- (LEChange *)changeForPropertyNamed:(NSString *)propertyName;
{
    assert(propertyName);

    NSPredicate *changePredicate = [NSPredicate predicateWithFormat:@"original == %@ && propertyName == %@", self, propertyName];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kLEChangeEntityName];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = changePredicate;

    NSArray *fetchResults;
    NSError *fetchError;
    if (!(fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError]))
        [fetchError present];

    return fetchResults.lastObject;
}

- (id)changeValueForGitHubKeyNamed:(NSString *)key;
{
    return [self changeValueForPropertyNamed:[[self class] GitHubKeysToPropertyNames][key]];
}

- (void)setChangeValue:(id)changeValue forGitHubKeyNamed:(NSString *)key;
{
    [self setChangeValue:changeValue forPropertyNamed:[[self class] GitHubKeysToPropertyNames][key]];
}

- (id)changeValueForPropertyNamed:(NSString *)propertyName;
{
    assert(propertyName);
    LEChange *change = [self changeForPropertyNamed:propertyName];
    if (!change)
        return nil;

    id changeValue = change.stringValue;
    NSError *validationError;
    if (![self validateValue:&changeValue forKey:propertyName error:&validationError]) {
        [validationError present];
        assert(NO);
    }

    return changeValue;
}

- (void)setChangeValue:(id)changeValue forPropertyNamed:(NSString *)propertyName;
{
    assert(propertyName);
    LEChange *change = [self changeForPropertyNamed:propertyName];
    if (!change) {
        change = [NSEntityDescription insertNewObjectForEntityForName:kLEChangeEntityName inManagedObjectContext:self.managedObjectContext];
        change.propertyName = propertyName;
        [[self mutableSetValueForKey:@"changes"] addObject:change]; 
    }

    if ([changeValue isKindOfClass:[NSString class]])
        change.stringValue = changeValue;
    else if ([changeValue isKindOfClass:[NSNumber class]])
        change.stringValue = [changeValue stringValue];
    else if ([changeValue isKindOfClass:[NSDate class]])
        change.stringValue = [NSDate GitHubDateStringWithDate:changeValue];
    else
        assert(NO);

    // To be safe let's save now, but if it becomes an issue, we can save outside of this operation.
    [[GHStore sharedStore] save];
}

@end


@implementation GHManagedObject (Deletion)

- (IBAction)die;
{
    // Subclasses should override this to call the appropriate deletion method from the shared store
    assert(NO);
}

@end


const NSTimeInterval kGHStoreUpdateLimit = 60.0f;

NSString * const kGHCreatedDatePropertyName = @"createdDate";
NSString * const kGHUpdatedDatePropertyName = @"lastUpdated";
NSString * const kGHModifiedDatePropertyName = @"modifiedDate";
