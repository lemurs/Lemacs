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
@end

@implementation GHManagedObject

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    return nil;
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
{
    NSDictionary *GitHubKeysToPropertyNames = [[self class] GitHubKeysToPropertyNames];
    GHManagedObject *object = self;
    [keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [object setValue:value forKey:GitHubKeysToPropertyNames[key]];
    }];
}

- (void)setValue:(id)value forKey:(NSString *)key;
{
    if (!value || !key)
        return;

    if ([value isEqual:[NSNull null]])
        return; // We may wish to treat this differently in the future to for example delete a previously set value.

    NSDictionary *properties = self.entity.propertiesByName;
    NSPropertyDescription *property = properties[key];
    if ([property isKindOfClass:[NSRelationshipDescription class]])
        return [self setUpRelationship:(NSRelationshipDescription *)property withValue:value forKey:key];

    assert([property isKindOfClass:[NSAttributeDescription class]]);
    NSAttributeDescription *attribute = (NSAttributeDescription *)property;

    switch (attribute.attributeType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            value = [NSNumber numberWithInteger:[value integerValue]];
            break;

        case NSDoubleAttributeType:
            value = [NSNumber numberWithDouble:[value doubleValue]];
            break;

        case NSFloatAttributeType:
            value = [NSNumber numberWithFloat:[value floatValue]];
            break;

        case NSDecimalAttributeType:
            value = [NSDecimalNumber decimalNumberWithString:value];
            break;

        case NSBooleanAttributeType:
            value = [NSNumber numberWithBool:[value boolValue]];
            break;

        case NSDateAttributeType:
            value = [NSDate dateWithGitHubDateString:value];
            break;

        case NSBinaryDataAttributeType:
            ; // TODO: Handle this case
            break;

        default:
            break;
    }
    
    [super setValue:value forKey:key];
}

- (void)setUpRelationship:(NSRelationshipDescription *)relationship withValue:(id)value forKey:(NSString *)key;
{
    if (relationship.isToMany)
        return [self setUpToManyRelationship:relationship withValue:(NSArray *)value forKey:key];

    if ([value isKindOfClass:[GHManagedObject class]])
        return [super setValue:value forKey:key];

    GHManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:relationship.destinationEntity.name inManagedObjectContext:self.managedObjectContext];
    assert([value isKindOfClass:[NSDictionary class]]);
    [object setValuesForKeysWithDictionary:(NSDictionary *)value];
    [super setValue:object forKey:key];

    NSString *inverseKey = relationship.inverseRelationship.name;
    if (inverseKey)
        [object setValue:self forKey:inverseKey];
}

- (void)setUpToManyRelationship:(NSRelationshipDescription *)relationship withValue:(NSArray *)values forKey:(NSString *)key;
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:values.count];

    [values enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
        GHManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:relationship.destinationEntity.name inManagedObjectContext:self.managedObjectContext];
        [object setValuesForKeysWithDictionary:(NSDictionary *)dictionary];
        [objects addObject:object];

        NSString *inverseKey = relationship.inverseRelationship.name;
        if (inverseKey)
            [object setValue:self forKey:inverseKey];

    }];

    id value = relationship.isOrdered ? [NSOrderedSet orderedSetWithArray:objects] : [NSSet setWithArray:objects];
    [super setValue:value forKey:key];
}

@end

NSString * const kGHCreatedDatePropertyName = @"createdDate";
