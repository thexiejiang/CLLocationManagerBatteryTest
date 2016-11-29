//
//  Logger.m
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 28/11/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logger.h"

@implementation Logger
{
    NSFileHandle  *_logFile;
}

+ (Logger *)shared
{
    static dispatch_once_t  dispatchOncePredicate = 0;
    static Logger  *shared = nil;
    
    
    if ( shared == nil )
    {
        //  Create a new object for the logging mechanism
        
        dispatch_block_t sharedLoggerInit = ^
        {
            //  Create the filename with the current date
            NSDateFormatter  *dateFormatter = [ NSDateFormatter new ];
            [ dateFormatter setDateFormat: @"(dd-MM-yyyy@HH.mm.ss)" ];
            
            NSString  *filename = [ NSString stringWithFormat:@"Battery_Optimisation_Test-%@.csv", [ dateFormatter stringFromDate: [ NSDate date ] ] ];
            
            NSString  *documentsDirectory = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES )[0];
            NSString  *strPath = [ documentsDirectory stringByAppendingPathComponent: filename ];
            
            //  Initialise the object with the created logfile name
            shared = [ (Logger *)[ super allocWithZone: NULL ] initWithFilename: strPath ];
        };
        
        dispatch_once( &dispatchOncePredicate, sharedLoggerInit);
    }
    
    return( shared );
}

/*
 *  Initialise the log file.
 */
- (id)initWithFilename: (NSString *)strFilename
{
    
    if ( ( self = [ super init ] ) )
    {
        if ( [ [ NSFileManager defaultManager ] createFileAtPath: strFilename contents: nil attributes: nil ] == YES )
        {
            _logFile = [ NSFileHandle fileHandleForWritingAtPath: strFilename ];
        }
    }
    
    return( self );
}


- (void)log:(NSString *)string, ...
{
    [ _logFile seekToEndOfFile ];
    
    va_list  args;
    va_start( args, string );
    
    
    
    static NSDateFormatter  *dateFormatter = nil;
    
    if ( dateFormatter == nil )
    {
        dateFormatter = [ NSDateFormatter new ];
        [ dateFormatter setDateFormat: @"(dd-MM-yyyy@HH.mm.ss.SSS)" ];
    }
    
    //  Write the message to file with an appended EOL
    //  Create the message with the variable arguments
    NSString *message = [ NSString stringWithFormat: @"%@|%@\n", [ dateFormatter stringFromDate: [ NSDate date ] ], [ [ NSString alloc ] initWithFormat: string arguments: args ] ];
    
    NSLog(@"%@", message);
    
    [ _logFile seekToEndOfFile ];
    [ _logFile writeData:[ message dataUsingEncoding:NSUTF8StringEncoding ] ];
    
    va_end( args );
}

@end
