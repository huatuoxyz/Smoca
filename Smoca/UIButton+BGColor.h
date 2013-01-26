//
//  UIButton+BGColor.h
//  Smoca
//
//  Created by Dongri Jin on 12/05/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton(BGColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (void)setBackgroundColorString:(NSString *)colorStr forState:(UIControlState)state;

@end
