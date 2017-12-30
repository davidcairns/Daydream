//
//  NSData+Extensions.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "NSData+Extensions.h"

@implementation NSData(DCExtensions)

- (NSString *)stringValue {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end
