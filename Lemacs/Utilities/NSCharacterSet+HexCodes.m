//
//  NSCharacterSet+HexCodes.m
//  Lemacs
//
//  Created by Mike Lee on 8/8/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NSCharacterSet+HexCodes.h"

@implementation NSCharacterSet (HexCodes)

+ (instancetype)hexadecimalCharacterSet;
{
    static NSCharacterSet *hexadecimalCharacterSet = nil;
    return hexadecimalCharacterSet ? : (hexadecimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789aAbBcCdDeEfF"]);

}

@end
