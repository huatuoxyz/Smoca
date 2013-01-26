//
//  UIColor+DRAdditions.m
//  Stagram
//
//  Created by 동일 김 on 11/12/02.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIColor+DRAdditions.h"

@implementation UIColor_DRAdditions

+ (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	//NSLog(@"HEX to RGB >> r:%f g:%f b:%f a:%f\n",r,g,b,a);
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
