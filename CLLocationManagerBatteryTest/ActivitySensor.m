//
//  ActivitySensor.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 28/11/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionActivityManager.h>
#import "ActivitySensor.h"
#import "LocationUpdateQueue.h"
#import "Logger.h"

@interface ActivitySensor ()

@property (nonatomic, assign) BOOL isImmobile;

@end

@implementation ActivitySensor
{
    CMMotionActivityManager *_activityManager;
    struct LocationProcessSetting _locationProcessSetting;
}

- (instancetype)initWithLocationProcessSetting:(struct LocationProcessSetting) locationProcessSetting
{
    self = [super init];
    if (self) {
        _activityManager = [CMMotionActivityManager new];
        _locationProcessSetting = locationProcessSetting;
    }
    return self;
}

- (void)start
{
    if ( _locationProcessSetting.activitySensorOn )
    {
        CMMotionActivityHandler activityHandler = ^(CMMotionActivity *activity)
        {
            self.isImmobile = activity.stationary && activity.confidence == CMMotionActivityConfidenceHigh;
        };
        
        [_activityManager startActivityUpdatesToQueue:LocationUpdateQueue() withHandler:activityHandler];
    }
}

- (void)setIsImmobile:(BOOL)isImmobile
{
    if ( _isImmobile != isImmobile )
    {
        if (isImmobile)
        {
            Log(@"Device is not moving.");
        }
        else
        {
            Log(@"Device is moving.");
        }
        
        _isImmobile = isImmobile;
    }
}



@end
