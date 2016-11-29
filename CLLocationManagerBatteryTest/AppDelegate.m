//
//  AppDelegate.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 21/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"
#import "LocationUpdateQueue.h"
#import "Logger.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIUserNotificationSettings
    *currentUserNotificationSettings = application.currentUserNotificationSettings,
    *notificationSettings;
    
    UIUserNotificationType
    requiredTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound,
    types;
    
    NSSet *categories;
    
    if( application.currentUserNotificationSettings == nil )
    {
        types      = requiredTypes;
        categories = nil;
    }
    else
    {
        types      = currentUserNotificationSettings.types | requiredTypes;
        categories = currentUserNotificationSettings.categories;
    }
    
    notificationSettings = [ UIUserNotificationSettings settingsForTypes: types
                                                              categories: categories ];
    
    [ application registerUserNotificationSettings: notificationSettings ];
    
    (void) LocationManager.instance;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Log(@"Application did enter background");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
