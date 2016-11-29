//
//  BackgroundTaskManager.h
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 13/11/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundTaskManager : NSObject

+ (instancetype)sharedBackgroundTaskManager;

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask;

@end

