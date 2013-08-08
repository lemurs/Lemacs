//
//  CIColor+HexCodes.m
//  Lemacs
//
//  Created by Mike Lee on 8/8/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "CIColor+HexCodes.h"
#import "NSCharacterSet+HexCodes.h"

@implementation CIColor (HexCodes)

+ (instancetype)colorWithHexCode:(NSString *)hexCode;
{
    static const NSUInteger kCIColorHexCodeLength = 6;
    static const NSUInteger kCIColorHexCodeSegmentLength = 2;
    NSAssert(hexCode.length == kCIColorHexCodeLength, @"%@ is an invalid code. It should be 6 hexadecimal digits.", hexCode);
    for (NSUInteger characterIndex = 0; characterIndex < kCIColorHexCodeLength; characterIndex++)
        if (![[NSCharacterSet hexadecimalCharacterSet] characterIsMember:[hexCode characterAtIndex:characterIndex]])
            NSAssert(NO, @"%@ is an invalid code. It should be 6 hexadecimal digits.", hexCode);

	// Separate into r, g, b substrings
	NSRange codeSegmentRange = NSMakeRange(0, kCIColorHexCodeSegmentLength);
	NSString *redCode = [hexCode substringWithRange:codeSegmentRange];

	codeSegmentRange.location = kCIColorHexCodeSegmentLength * 1;
	NSString *greenCode = [hexCode substringWithRange:codeSegmentRange];

	codeSegmentRange.location = kCIColorHexCodeSegmentLength * 2;
	NSString *blueCode = [hexCode substringWithRange:codeSegmentRange];

	unsigned int red, green, blue;
	[[NSScanner scannerWithString:redCode] scanHexInt:&red];
	[[NSScanner scannerWithString:greenCode] scanHexInt:&green];
	[[NSScanner scannerWithString:blueCode] scanHexInt:&blue];

    static const CGFloat kCIColorHexCodeMax = 255.0f;
	return [self colorWithRed:((CGFloat)red / kCIColorHexCodeMax) green:((CGFloat)green / kCIColorHexCodeMax) blue:((CGFloat)blue / kCIColorHexCodeMax)];
}

@end
