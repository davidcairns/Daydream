//
//  DCTouchpad.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "DCControllerButton.h"

@class DCTouchpad;
typedef void (^DCTouchpadPointChangedHandler)(DCTouchpad * _Nonnull, CGPoint);

@interface DCTouchpad : NSObject

@property(nonatomic, assign)CGPoint point;

@property(nonatomic, strong)DCTouchpadPointChangedHandler _Nullable pointChangedHandler;

@property(nonatomic, strong)DCControllerButton * _Nonnull button;

@end
