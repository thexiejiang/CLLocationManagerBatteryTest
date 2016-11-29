//
//  LocationManager.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "LocationManagerProxy.h"
#import "LocationSensor.h"
#import "LocationUpdateQueue.h"
#import "ActivitySensor.h"
#import "LocationProcessSetting.h"

@implementation LocationManager
{
    LocationSensor          *_locationSensor;
    ActivitySensor          *_activitySensor;
    LocationManagerProxy    *_proxy;
    
    struct LocationProcessSetting _locationProcessSetting;
}

+ (LocationManager *)instance
{
    static LocationManager *instance = nil;
    static dispatch_once_t dispatchOncePredicate = 0;
    
    dispatch_block_t singletonInit = ^
    {
        instance = [ (LocationManager *)[ super alloc ] init ];
        [ instance singletonInit ];
    };
    
    dispatch_once( &dispatchOncePredicate, singletonInit );
    
    return( instance );
}

- (void)singletonInit
{
    self.pausesLocationUpdatesAutomatically = NO;
    self.allowsBackgroundLocationUpdates = YES;
    self.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    _locationProcessSetting.accuracySwitchOn = NO;
    _locationProcessSetting.activitySensorOn = NO;
    _locationProcessSetting.monitorRegionOn = YES;
    
    _locationSensor = [ [ LocationSensor alloc ] initWithLocationManager:self andLocationProcessSetting: _locationProcessSetting ];
    _activitySensor = [ [ ActivitySensor alloc ] initWithLocationProcessSetting:_locationProcessSetting ];
    _proxy = [ [ LocationManagerProxy alloc ] initWithLocationSensor:_locationSensor ];
    
    self.delegate = _proxy;
    
    [ LocationUpdateQueue() addOperationWithBlock: ^{
        [ _locationSensor start ];
        [ _activitySensor start ];
    } ];
}

@end
