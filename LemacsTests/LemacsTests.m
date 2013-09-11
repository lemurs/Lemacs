//
//  LemacsTests.m
//  LemacsTests
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSDate+GitHub.h"

@interface LemacsTests : XCTestCase

@end

@implementation LemacsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testGitHubDateFormat
{
    NSDate * date = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
    NSString * gitDate = [NSDate GitHubDateStringWithDate: date];
    XCTAssertEqualObjects(@"2001-01-01T00:00:00Z", gitDate);
}

@end
