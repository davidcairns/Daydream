//
//  NSData+Extensions.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A `Data` extension for conveniently transforming `Data` into a hex string, string, or integer.
@interface NSData (DCExtensions)

@property(nonatomic, readonly)NSString * _Nonnull stringValue;

@end
