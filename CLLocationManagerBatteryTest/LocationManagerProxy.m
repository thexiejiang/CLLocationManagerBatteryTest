//
//  LocationManagerProxy.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "LocationManagerProxy.h"
#import "LocationUpdateQueue.h"
#import "LocationSensor.h"
#import "BackgroundTaskManager.h"
#import "Logger.h"

@implementation LocationManagerProxy
{
    LocationSensor *_locationSensor;
}

- (instancetype)initWithLocationSensor:(LocationSensor *)locationSensor
{
    NSParameterAssert(locationSensor);
    
    self = [super init];
    
    if( self )
    {
        _locationSensor = locationSensor;
    }
    return self;
}

# pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSAssert(NSOperationQueue.currentQueue == NSOperationQueue.mainQueue, @"Location manager proxy needs to be run on the main queue");
    
    dispatch_block_t processLocationUpdates = ^
    {
        NSAssert(NSOperationQueue.currentQueue == LocationUpdateQueue(), @"Location update process needs to be run on location update queue");
        
        [ _locationSensor didUpdateLocations: locations ];
    };
    
    DispatchBackgroundSafeTaskWithQueue( processLocationUpdates, LocationUpdateQueue() );
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ( region.identifier == AppRestartRegionIdentifier )
    {
        Log( @"App monitoring region has been exited" );
        [ _locationSensor resetRegionMonitoring ];
    }
}

@end

