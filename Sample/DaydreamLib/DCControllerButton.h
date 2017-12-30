//
//  DCControllerButton.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DCControllerButton;
typedef void(^DCControllerButtonChangedHandler)(DCControllerButton *_Nonnull, bool pressed);

@interface DCControllerButton : NSObject

@property(nonatomic, strong)DCControllerButtonChangedHandler _Nullable pressedHandler;

@property(nonatomic, assign)BOOL pressed;

@end
