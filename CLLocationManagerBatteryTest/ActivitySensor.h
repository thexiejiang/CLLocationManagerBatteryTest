//
//  ActivitySensor.h
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 28/11/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "LocationProcessSetting.h"

@interface ActivitySensor : NSObject

- (instancetype)initWithLocationProcessSetting:(struct LocationProcessSetting) locationProcessSetting;

- (void)start;

@end
