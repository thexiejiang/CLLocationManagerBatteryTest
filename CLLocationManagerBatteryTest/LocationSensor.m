//
//  LocationSensor.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLCircularRegion.h>
#import "LocationSensor.h"
#import "BackgroundTaskManager.h"
#import "LocationUpdateQueue.h"
#import "Logger.h"

@implementation LocationSensor
{
    __weak LocationManager *_locationManager;
    
    struct LocationProcessSetting _locationProcessSetting;
    
    NSTimer *_resumeLocationUpdateTimer;
    NSTimer *_pauseLocationUpdateTimer;
    
    CLCircularRegion *_monitoringRegion;
}

- (instancetype)initWithLocationManager:(LocationManager *)locationManager andLocationProcessSetting:(struct LocationProcessSetting)locationProcessSetting
{
    self = [super init];
    if(self)
    {
        _locationManager = locationManager;
        _locationProcessSetting = locationProcessSetting;
        _location = nil;
        _monitoringRegion = nil;
    }
    return self;
}

- (void)start
{
    [ NSOperationQueue.mainQueue addOperationWithBlock: ^{
        [ _locationManager requestAlwaysAuthorization ];
        [ _locationManager startUpdatingLocation ];
    } ];
}

- (void)setLocation:(CLLocation *)location
{
    _location = location;
    
    if ( _locationProcessSetting.monitorRegionOn )
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self startMonitorForRegionWithLocation:location];
        }];
    }
}

- (void)startMonitorForRegionWithLocation: (CLLocation *)location
{
    if ( _monitoringRegion == nil )
    {
        CLLocationDistance radius = MAX(_locationManager.maximumRegionMonitoringDistance, 200.0);
        
        //  Create a new region for resurrection
        _monitoringRegion = [ [ CLCircularRegion alloc ] initWithCenter: location.coordinate
                                                                 radius: radius
                                                             identifier: AppRestartRegionIdentifier ];
        
        _monitoringRegion.notifyOnEntry = NO;
        _monitoringRegion.notifyOnExit  = YES;
        
        [_locationManager startMonitoringForRegion:_monitoringRegion];
        Log( @"App region monitoring has been started" );
    }
}

- (void)resetRegionMonitoring
{
    [_locationManager stopMonitoringForRegion:_monitoringRegion];
    
    _monitoringRegion = nil;
}

- (void)didUpdateLocations: (NSArray *)locations
{
    NSParameterAssert(locations);
    
    //  Loop through each of the locations within the list to ensure any observers of the location instance variable are updated
    for( CLLocation *coreLocation in locations )
    {
        [ self willChangeValueForKey: @"location" ];
        
        self.location = coreLocation;
        
        [ self logLocationUpdate: coreLocation ];
        
        [ self didChangeValueForKey: @"location" ];
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //If the timer still valid, return it (Will not run the code below)
        if (_resumeLocationUpdateTimer == nil)
        {
            [[BackgroundTaskManager sharedBackgroundTaskManager] beginNewBackgroundTask];
            
            //Restart the locationMaanger after 1 minute
            _resumeLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                                        selector:@selector(restartLocationUpdates)
                                                                        userInfo:nil
                                                                         repeats:NO];
            
            [[NSRunLoop currentRunLoop] addTimer:_resumeLocationUpdateTimer forMode:NSRunLoopCommonModes];
            
            //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
            //The location manager will only operate for 10 seconds to save battery
            if (_pauseLocationUpdateTimer)
            {
                [_pauseLocationUpdateTimer invalidate];
                _pauseLocationUpdateTimer = nil;
            }
            
            _pauseLocationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                                       selector:@selector(stopLocationDelayBy10Seconds)
                                                                       userInfo:nil
                                                                        repeats:NO];
            
            [[NSRunLoop currentRunLoop] addTimer:_pauseLocationUpdateTimer forMode:NSRunLoopCommonModes];
        }
    }];
}

- (void) restartLocationUpdates
{
    Log(@"Restart location updates");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (_resumeLocationUpdateTimer) {
            [_resumeLocationUpdateTimer invalidate];
            _resumeLocationUpdateTimer = nil;
        }
        
        if ( _locationProcessSetting.accuracySwitchOn )
        {
            _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        }
        [_locationManager startUpdatingLocation];

    }];
}

-(void)stopLocationDelayBy10Seconds{
    Log(@"Stop location updates");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ( _locationProcessSetting.accuracySwitchOn )
        {
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }
        [_locationManager stopUpdatingLocation];
    }];
}

- (void)logLocationUpdate:(CLLocation *)locationUpdate
{
    NSArray *paths                 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory   = [ paths objectAtIndex:0 ];
    NSString *documentPath         = [ documentsDirectory stringByAppendingPathComponent: @"LocationUpdate-Stats.csv" ];
    NSString *locationUpdateString = [ self locationUpdateString: locationUpdate ];
    
    NSFileManager *fileManager = [ NSFileManager defaultManager ];
    
    if ( ![ fileManager fileExistsAtPath: documentPath ] )
    {
        [ locationUpdateString writeToFile: documentPath
                                atomically: YES
                                  encoding: NSUTF8StringEncoding
                                     error: nil ];
    }
    else
    {
        NSFileHandle *fileHandle = [ NSFileHandle fileHandleForWritingAtPath:documentPath ];
        [ fileHandle seekToEndOfFile ];
        [ fileHandle writeData:[ locationUpdateString dataUsingEncoding:NSUTF8StringEncoding ] ];
    }
}

- (NSString *)locationUpdateString:(CLLocation *)location
{
    NSDateFormatter *dateFormatter=[ [ NSDateFormatter alloc ] init ];
    [ dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss" ];
    NSString * currentDateAndTime = [ dateFormatter stringFromDate:[ NSDate date ] ];
    
    NSString *locationUpdate = currentDateAndTime;
    
    NSString *coordinate = [ NSString stringWithFormat:@",%f,%f", location.coordinate.latitude, location.coordinate.longitude ];
    NSString *accuracy   = [ NSString stringWithFormat:@",%f", location.horizontalAccuracy ];
    
    locationUpdate = [locationUpdate stringByAppendingString: coordinate];
    locationUpdate = [locationUpdate stringByAppendingString: accuracy];
    
    Log(@"Location update: %@", locationUpdate);
    
    locationUpdate = [locationUpdate stringByAppendingString: @"\n"];
    
    return locationUpdate;
}

@end
