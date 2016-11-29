//
//  LocationManager.h
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <CoreLocation/CLLocationManager.h>

@interface LocationManager : CLLocationManager

+ (LocationManager *)instance;

@end
