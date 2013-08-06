//
//  LEOptionsViewController.m
//  Lemacs
//
//  Created by Mike Lee on 8/6/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LEOptionsViewController.h"

@implementation LEOptionsViewController

+ (instancetype)optionsController;
{
    return [[self alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end
