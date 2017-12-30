//
//  DCControllerButton.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "DCControllerButton.h"

@implementation DCControllerButton

- (void)setPressed:(BOOL)pressed {
    const BOOL didChange = (_pressed != pressed);
    _pressed = pressed;
    
    if(didChange) {
        if(self.pressedHandler) {
            self.pressedHandler(self, pressed);
        }
    }
}

@end
