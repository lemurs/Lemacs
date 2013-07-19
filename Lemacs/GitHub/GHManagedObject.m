//
//  GHManagedObject.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHManagedObject.h"
#import "NSDate+GitHub.h"

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
    NSDictionary *properites = self.entity.propertiesByName;
    NSAttributeDescription *attribute = properites[key];
    NSAssert([attribute isKindOfClass:[NSAttributeDescription class]], @"Property %@ is not an attribute. It is: %@", key, attribute);

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

@end
