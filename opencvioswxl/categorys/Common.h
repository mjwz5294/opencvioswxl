//
//  Common.h
//  Lightning DS
//
//  Created by mac on 14-10-13.
//  Copyright (c) 2014年 com.zte-v. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


extern BOOL isDeviceIPad();


@interface NSObject (PerformBlockAfterDelay)
- (void)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay inModes:(NSArray*)modes;

- (UIViewController *)topViewController;
@end

@interface UIViewController (extension)
- (id)initFromXib;
@end

@interface UIView (center)
- (void)centerInContainer:(UIView*)container;
@end

@interface UIView (InitFromNib)
+ (id)viewFromNib;
@end

@interface NSDictionary (Utility)
- (id)objectForKeyNotNull:(id)key;
@end

@interface NSNumber(Date)
- (NSString *)toDateString;
- (NSString *)toDateStringTime;
@end
