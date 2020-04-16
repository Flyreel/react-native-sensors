//  Accelerometer.m

#import "Accelerometer.h"
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

@implementation Accelerometer

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

- (id) init {
    self = [super init];
    NSLog(@"Accelerometer");

    if (self) {
        self->_motionManager = [[CMMotionManager alloc] init];
        self->_deviceMotion = [[CMDeviceMotion alloc] init];
        self->logLevel = 0;
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"Accelerometer"];
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_REMAP_METHOD(isAvailable,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    return [self isAvailableWithResolver:resolve
                                rejecter:reject];
}

- (void) isAvailableWithResolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject {
    if([self->_motionManager isAccelerometerAvailable])
    {
        /* Start the accelerometer if it is not active already */
        if([self->_motionManager isAccelerometerActive] == NO)
        {
            resolve(@YES);
        } else {
            reject(@"-1", @"Accelerometer is not active", nil);
        }
    }
    else
    {
        reject(@"-1", @"Accelerometer is not available", nil);
    }
}

RCT_EXPORT_METHOD(setUpdateInterval:(double) interval) {
    if (self->logLevel > 0) {
        NSLog(@"setUpdateInterval: %f", interval);
    }

    double intervalInSeconds = interval / 1000;

    [self->_motionManager setDeviceMotionUpdateInterval:intervalInSeconds];
}

RCT_EXPORT_METHOD(setLogLevel:(int) level) {
    if (level > 0) {
        NSLog(@"setLogLevel: %f", level);
    }

    self->logLevel = level;
}

RCT_EXPORT_METHOD(getUpdateInterval:(RCTResponseSenderBlock) cb) {
    double interval = self->_motionManager.deviceMotionUpdateInterval;

    if (self->logLevel > 0) {
        NSLog(@"getUpdateInterval: %f", interval);
    }

    cb(@[[NSNull null], [NSNumber numberWithDouble:interval]]);
}

RCT_EXPORT_METHOD(getData:(RCTResponseSenderBlock) cb) {
    double x = self->_motionManager.accelerometerData.gravity.x;
    double y = self->_motionManager.accelerometerData.gravity.y;
    double z = self->_motionManager.accelerometerData.gravity.z;

    if (self->logLevel > 0) {
        NSLog(@"getData: %f, %f, %f", x, y, z);
    }

    cb(@[[NSNull null], @{
                 @"x" : [NSNumber numberWithDouble:x],
                 @"y" : [NSNumber numberWithDouble:y],
                 @"z" : [NSNumber numberWithDouble:z]
             }]
       );
}

RCT_EXPORT_METHOD(startUpdates) {
    if (self->logLevel > 0) {
        NSLog(@"startUpdates/startAccelerometerUpdates");
    }

    [self->_motionManager startDeviceMotionUpdates];

    /* Receive the accelerometer data on this block */
    [self->_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                               withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         double x = data.gravity.x;
         double y = data.gravity.y;
         double z = data.gravity.z;

         if (self->logLevel > 1) {
             NSLog(@"Updated accelerometer values: %f, %f, %f", x, y, z);
         }

         [self sendEventWithName:@"Accelerometer" body:@{
                                                                                   @"x" : [NSNumber numberWithDouble:x],
                                                                                   @"y" : [NSNumber numberWithDouble:y],
                                                                                   @"z" : [NSNumber numberWithDouble:z]
                                                                               }];
     }];

}

RCT_EXPORT_METHOD(stopUpdates) {
    if(self->logLevel > 0) {
        NSLog(@"stopUpdates");
    }

    [self->_motionManager stopAccelerometerUpdates];
}

@end
