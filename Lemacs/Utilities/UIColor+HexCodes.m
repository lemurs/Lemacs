//
//  UIColor+HexCodes.m
//  Lemur Chemistry
//
//  Created by Mike Lee on 8/11/12.
//  Copyright (c) 2012 New Lemurs. All rights reserved.
//

#import "UIColor+HexCodes.h"


@interface NSCharacterSet (HexCodes)
+ (NSCharacterSet *)hexadecimalCharacterSet;
@end

@implementation NSCharacterSet (HexCodes)

+ (NSCharacterSet *)hexadecimalCharacterSet;
{
    static NSCharacterSet *hexadecimalCharacterSet = nil;
    return hexadecimalCharacterSet ? : (hexadecimalCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"]);

}

@end

@implementation UIColor (HexCodes)

+ (UIColor *)colorWithHexCode:(NSString *)hexCode;
{
    static const NSUInteger kUIColorHexCodeLength = 6;
    static const NSUInteger kUIColorHexCodeSegmentLength = 2;
    NSAssert(hexCode.length == kUIColorHexCodeLength, @"%@ is an invalid code. It should be 6 hexadecimal digits.", hexCode);
    for (NSUInteger characterIndex = 0; characterIndex < kUIColorHexCodeLength; characterIndex++)
        if (![[NSCharacterSet hexadecimalCharacterSet] characterIsMember:[hexCode characterAtIndex:characterIndex]])
            NSAssert(NO, @"%@ is an invalid code. It should be 6 hexadecimal digits.", hexCode);

	// Separate into r, g, b substrings
	NSRange codeSegmentRange = NSMakeRange(0, kUIColorHexCodeSegmentLength);
	NSString *redCode = [hexCode substringWithRange:codeSegmentRange];

	codeSegmentRange.location = kUIColorHexCodeSegmentLength * 1;
	NSString *greenCode = [hexCode substringWithRange:codeSegmentRange];

	codeSegmentRange.location = kUIColorHexCodeSegmentLength * 2;
	NSString *blueCode = [hexCode substringWithRange:codeSegmentRange];

	unsigned int red, green, blue;
	[[NSScanner scannerWithString:redCode] scanHexInt:&red];
	[[NSScanner scannerWithString:greenCode] scanHexInt:&green];
	[[NSScanner scannerWithString:blueCode] scanHexInt:&blue];

    static const CGFloat kUIColorHexCodeMax = 255.0f;
	return [self colorWithRed:((CGFloat)red / kUIColorHexCodeMax) green:((CGFloat)green / kUIColorHexCodeMax) blue:((CGFloat)blue / kUIColorHexCodeMax) alpha:1.0f];
}

@end
