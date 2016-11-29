//
//  LocationUpdateQueue.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LocationUpdateQueue.h"
#import "Logger.h"

NSOperationQueue *LocationUpdateQueue( void )
{
    static dispatch_once_t once;
    static NSOperationQueue* pointQueue = NULL;
    
    dispatch_once(&once, ^
      {
          pointQueue = [NSOperationQueue new];
          [pointQueue setName:@"BDPointSDK Queue"];
          pointQueue.maxConcurrentOperationCount = 1;
      });
    
    return pointQueue;
}

void DispatchBackgroundSafeTaskWithQueue( dispatch_block_t task, NSOperationQueue* queue )
{
    dispatch_block_t defaultExpirationHandler = ^
    {
        Log(@"Background task expired");
    };
    
    UIBackgroundTaskIdentifier backgroundTaskIdentifier =
    [UIApplication.sharedApplication beginBackgroundTaskWithName: @"BackgroundSafeTask"
                                               expirationHandler: defaultExpirationHandler ];
    
    // Operations may be scheduled on the execution queue during this task
    if( queue == NSOperationQueue.currentQueue )
    {
        task();
    }
    else
    {
        [ queue addOperationWithBlock: task ];
    }
    
    dispatch_block_t endBackgroundTask = ^
    {
        [ UIApplication.sharedApplication endBackgroundTask:backgroundTaskIdentifier ];
    };
    
    // Ensure that the UIApplication background-task token is only released after other scheduled tasks complete
    [ queue addOperationWithBlock: endBackgroundTask ];
}
