//
//  Logger.h
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 28/11/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#define Log( fmt, ... )       [ [ Logger shared ] log: fmt, ##__VA_ARGS__ ]

@interface Logger : NSObject

+ (Logger *)shared;

- (void)log:(NSString *)string, ...;

@end
