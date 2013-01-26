//
//  DRScreenStatus.m
//  Stagram
//
//  Created by Dongri Jin on 2012/10/07.
//
//

#import "DRScreenStatus.h"

@implementation DRScreenStatus
+ (BOOL)is4inch
{
    CGSize screenSize = [[self mainScreen] bounds].size;
    return screenSize.width == 320.0 && screenSize.height == 568.0;
}
+ (BOOL)isRetina
{
    if ([[UIScreen mainScreen] scale]==2) {
        return YES;
    }
    return NO;
}
@end
