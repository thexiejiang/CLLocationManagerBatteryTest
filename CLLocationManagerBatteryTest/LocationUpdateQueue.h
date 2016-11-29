//
//  LocationUpdateQueue.h
//  CLLocationManagerBatteryTest
//
//  Created by Jason Xie on 24/10/16.
//  Copyright © 2016 Bluedot Innovation. All rights reserved.
//

NSOperationQueue *LocationUpdateQueue( void );

void DispatchBackgroundSafeTaskWithQueue( dispatch_block_t task, NSOperationQueue* queue );
