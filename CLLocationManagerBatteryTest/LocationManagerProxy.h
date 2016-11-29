//
//  LocationManagerProxy.h
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <CoreLocation/CLLocationManagerDelegate.h>

@class LocationSensor;

@interface LocationManagerProxy : NSObject <CLLocationManagerDelegate>

- (instancetype)initWithLocationSensor:(LocationSensor *)locationSensor;

@end
