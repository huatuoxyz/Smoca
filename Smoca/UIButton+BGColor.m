//
//  UIButton+BGColor.m
//  Smoca
//
//  Created by Dongri Jin on 12/05/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIButton+BGColor.h"

#import <QuartzCore/QuartzCore.h>

#import "UIColor+DRAdditions.h"

@implementation UIButton (BGColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    CGRect buttonSize = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIView *bgView = [[[UIView alloc] initWithFrame:buttonSize] autorelease];
    bgView.layer.cornerRadius = 5;
    bgView.layer.borderWidth = 1.0f;
    bgView.layer.borderColor = [[UIColor grayColor] CGColor];
    bgView.clipsToBounds = true;
    bgView.backgroundColor = color;
    UIGraphicsBeginImageContext(self.frame.size);
    [bgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:screenImage forState:state];
}

- (void)setBackgroundColorString:(NSString *)colorStr forState:(UIControlState)state {
    UIColor *color = [UIColor_DRAdditions hexToUIColor:colorStr alpha:1];
    [self setBackgroundColor:color forState:state];
}

@end
