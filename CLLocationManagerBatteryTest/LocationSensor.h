//
//  LocationSensor.h
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "LocationManager.h"
#import "LocationProcessSetting.h"

static NSString *AppRestartRegionIdentifier = @"__AppRestart";

@interface LocationSensor : NSObject

@property (nonatomic,readonly) CLLocation* location;

- (instancetype)initWithLocationManager:(LocationManager *)locationManager andLocationProcessSetting:(struct LocationProcessSetting) locationProcessSetting;

- (void)start;

- (void)didUpdateLocations: (NSArray *)locations;

- (void)resetRegionMonitoring;

@end
