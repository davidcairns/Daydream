//
//  DCTouchpad.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "DCTouchpad.h"

@implementation DCTouchpad

- (instancetype)init {
    if((self = [super init])) {
        self.point = CGPointZero;
        self.button = [[DCControllerButton alloc] init];
    }
    return self;
}

- (void)setPoint:(CGPoint)point {
    _point = point;
    if(self.pointChangedHandler) {
        self.pointChangedHandler(self, point);
    }
}

@end
