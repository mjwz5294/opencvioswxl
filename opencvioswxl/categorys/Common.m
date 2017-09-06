//
//  Common.m
//  Lightning DS
//
//  Created by mac on 14-10-13.
//  Copyright (c) 2014年 com.zte-v. All rights reserved.
//

#import "Common.h"


BOOL isDeviceIPad()
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
#endif
    return NO;
}

BOOL resourceExists(NSString*resourceName, NSString *resourceType)
{
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


@implementation NSObject(PerformBlockAfterDelay)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    id _block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:) withObject:_block afterDelay:delay];
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay inModes:(NSArray*)modes
{
    id _block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:) withObject:_block afterDelay:delay inModes:modes];
}

- (void)fireBlockAfterDelay:(void(^)(void))block
{
    if (block) {
        block();
    }
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}



@end

@implementation UIViewController (extension)

- (id)initFromXib
{
    NSString *className = NSStringFromClass(self.class);
    NSString *xibName = isDeviceIPad() ? [className stringByAppendingString:@"~ipad"] : [className stringByAppendingString:@"~iphone"];
    
    if (!resourceExists(xibName, @"nib")) {
        xibName = className;
        if (!resourceExists(xibName, @"nib")) {
            xibName = nil;
        }
    }
    self = [self initWithNibName:xibName bundle:nil];
    
    return self;
}
@end

@implementation UIView (center)

- (void)centerInContainer:(UIView *)container
{
    CGRect rect = self.frame;
    rect.origin.x = ceilf((container.bounds.size.width - rect.size.width) / 2.0);
    rect.origin.y = ceilf((container.bounds.size.height - rect.size.height) / 2.0);
    self.frame = rect;
}

@end

@implementation UIView (InitFromNib)

+ (id)viewFromNib
{
    NSString *viewClassName = NSStringFromClass([self class]);
    NSString *xibName = isDeviceIPad() ? [NSString stringWithFormat:@"%@~iPad", viewClassName] : [NSString stringWithFormat:@"%@~iPhone", viewClassName];
    NSArray *xibs = nil;
    if (resourceExists(xibName, @"nib")) {
        xibs = [[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil];
    }
    else if (resourceExists(viewClassName, @"nib")) {
        xibs = [[NSBundle mainBundle] loadNibNamed:viewClassName owner:nil options:nil];
    }
    
    if ([xibs count] > 0) {
        return xibs[0];
    }
    else {
        return nil;
    }
}
@end

@implementation NSDictionary (Utility)

// in case of [NSNull null] values a nil is returned ...
- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null])
        return nil;
    
    return object;
}

@end

@implementation NSNumber(Date)

- (NSString *)toDateString
{
    int seconds = [self intValue];
    int h = seconds / 3600;
    int m = (seconds - h * 3600) / 60;
    int s = (seconds - h * 3600) - m * 60;
    
    NSString *hour = @"";
    NSString *minute = @"";
    NSString *second = @"";
    
    if (h > 9) {
        hour = [NSString stringWithFormat:@"%d", h];
    }
    else if(h > 0) {
        hour = [NSString stringWithFormat:@"0%d", h];
    }
    
    if (m > 9) {
        minute = [NSString stringWithFormat:@"%d", m];
    }
    else if(minute >= 0) {
        minute = [NSString stringWithFormat:@"0%d", m];
    }
    
    if (s > 9) {
        second = [NSString stringWithFormat:@"%d", s];
    }
    else if(s >= 0) {
        second = [NSString stringWithFormat:@"0%d", s];
    }
    
    if (hour.length > 0) {
        return [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];
    }
    else if (minute.length > 0) {
        return [NSString stringWithFormat:@"%@:%@", minute, second];
    }
    else {
        return [NSString stringWithFormat:@"%@", second];
    }
}

- (NSString *)toDateStringTime{
    int seconds = [self intValue];
    int h = seconds / 3600;
    int m = (seconds - h * 3600) / 60;
    int s = (seconds - h * 3600) - m * 60;
    
    NSString *hour = @"";
    NSString *minute = @"";
    NSString *second = @"";
    
    if (h > 9) {
        hour = [NSString stringWithFormat:@"%d", h];
    }
    else if(h > 0) {
        hour = [NSString stringWithFormat:@"%d", h];
    }
    
    if (m > 9) {
        minute = [NSString stringWithFormat:@"%d", m];
    }
    else if(minute >= 0 && h < 1) {
        minute = [NSString stringWithFormat:@"%d", m];
    }
    
    if (s > 9) {
        second = [NSString stringWithFormat:@"%d", s];
    }
    else if(s >= 0) {
        second = [NSString stringWithFormat:@"0%d", s];
    }
    
    if (hour.length > 0) {
        return [NSString stringWithFormat:@"%@:%@:%@", hour, minute, second];
    }
    else if (minute.length > 0) {
        return [NSString stringWithFormat:@"%@:%@", minute, second];
    }
    else {
        return [NSString stringWithFormat:@"%@", second];
    }
}
@end

