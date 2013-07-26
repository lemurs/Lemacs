//
//  GHManagedObject.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject.h"
#import "NSDate+GitHub.h"


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
    NSPredicate *predicate = indexPropertyValue ? [NSPredicate predicateWithFormat:@"%@ == %@" argumentArray:@[indexPropertyName, indexPropertyValue]] : nil;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = predicate;

    NSArray *fetchResults;
    NSError *fetchError;
    if (!(fetchResults = [context executeFetchRequest:fetchRequest error:&fetchError]))
        NSLog(@"Fetch Error: %@ %@", NSStringFromSelector(_cmd), fetchError.localizedDescription);

    id managedObject = fetchResults.lastObject;
    if (managedObject) // Existing object found!
        return managedObject;

    // Create a new object
    managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    [managedObject setValue:indexPropertyValue forKey:indexPropertyName];
    [managedObject setValue:[NSDate distantPast] forKey:kGHUpdatedDatePropertyName];

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
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), validationError.localizedDescription);
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
            NSLog(@"%@ %@", NSStringFromSelector(_cmd), validationError.localizedDescription);

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
    NSLog(@"%@ %@ : %@", NSStringFromSelector(_cmd), key, *value);

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
                return NO;

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

//    NSString *inverseKey = relationship.inverseRelationship.name;
//    if (inverseKey)
//        [object setValue:self forKey:inverseKey];
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

//        NSString *inverseKey = relationship.inverseRelationship.name;
//        if (inverseKey)
//            [object setValue:self forKey:inverseKey];

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

    if (![*value isKindOfClass:[NSDictionary class]])
        return NO;

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
        return NO;

    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[*values count]];
    [*values enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
        if (![dictionary isKindOfClass:[NSDictionary class]])
            *stop = YES;

        GHManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:relationship.destinationEntity.name inManagedObjectContext:self.managedObjectContext];
        [object setValuesForKeysWithDictionary:(NSDictionary *)dictionary];
        [objects addObject:object];

//        NSString *inverseKey = relationship.inverseRelationship.name;
//        if (inverseKey)
//            [object setValue:self forKey:inverseKey];

    }];

    *values = objects;

    return YES;
}

@end

const NSTimeInterval kGHStoreUpdateLimit = 60.0f;

NSString * const kGHCreatedDatePropertyName = @"createdDate";
NSString * const kGHUpdatedDatePropertyName = @"lastUpdated";
NSString * const kGHModifiedDatePropertyName = @"modifiedDate";
