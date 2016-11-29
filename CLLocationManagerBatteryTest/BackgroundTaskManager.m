//
//  BackgroundTaskManager.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 13/11/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"
#import "Logger.h"

@interface BackgroundTaskManager()

@property (nonatomic, strong)NSMutableArray* backgroundTaskIdList;

@end

@implementation BackgroundTaskManager
{
    NSDate *_didEnterBackgroundDate;
}

+(instancetype)sharedBackgroundTaskManager{
    static BackgroundTaskManager* sharedBGTaskManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBGTaskManager = [[BackgroundTaskManager alloc] init];
    });
    
    return sharedBGTaskManager;
}

-(id)init{
    self = [super init];
    if(self){
        _backgroundTaskIdList = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)applicationDidEnterBackground
{
    _didEnterBackgroundDate = [NSDate date];
}

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask
{
    UIApplication* application = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier backgroundTaskId = UIBackgroundTaskInvalid;
    
    if( [ application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:) ] )
    {
        backgroundTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            NSTimeInterval timeIntervalSinceEnterBackground = [[NSDate date] timeIntervalSinceDate:_didEnterBackgroundDate];
            
            Log(@"background task id %lu expired after %@", (unsigned long)backgroundTaskId, [[NSDateComponentsFormatter new] stringFromTimeInterval:timeIntervalSinceEnterBackground]);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UILocalNotification *notification = [UILocalNotification new];
                notification.alertBody = [NSString stringWithFormat:@"Background task id %lu expired after %@", (unsigned long)backgroundTaskId, [[NSDateComponentsFormatter new] stringFromTimeInterval:timeIntervalSinceEnterBackground]];
                [UIApplication.sharedApplication presentLocalNotificationNow:notification];
            }];
            
            [_backgroundTaskIdList removeObject:@(backgroundTaskId)];
            [application endBackgroundTask:backgroundTaskId];
            backgroundTaskId = UIBackgroundTaskInvalid;
        }];
        
        [self endBackgroundTasks];
        
        if ( application.backgroundTimeRemaining < DBL_MAX ) Log(@"The amount of time the app has to run in the background:  %f", application.backgroundTimeRemaining);
        
        //add this id to our list
        Log(@"Started background task %lu", (unsigned long)backgroundTaskId);
        [_backgroundTaskIdList addObject:@(backgroundTaskId)];
    }
    
    return backgroundTaskId;
}

-(void)endBackgroundTasks
{
    //mark end of each of our background task
    UIApplication* application = [UIApplication sharedApplication];
    
    if([application respondsToSelector:@selector(endBackgroundTask:)])
    {
        for ( NSNumber *backgroundTaskIdNumber in _backgroundTaskIdList )
        {
            UIBackgroundTaskIdentifier backgroundTaskId = [backgroundTaskIdNumber integerValue];
            
            Log(@"Ending background task %lu", (unsigned long)backgroundTaskId);
            
            [application endBackgroundTask:backgroundTaskId];
            [_backgroundTaskIdList removeObjectAtIndex:0];
        }
    }
}

@end
