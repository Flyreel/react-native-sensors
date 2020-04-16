// Inspired by https://github.com/pwmckenna/react-native-motion-manager

#import "Gyroscope.h"
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

@implementation Gyroscope

@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

- (id) init {
    self = [super init];
    NSLog(@"Gyroscope");

    if (self) {
        self->_motionManager = [[CMMotionManager alloc] init];
        self->_deviceMotion = [[CMDeviceMotion alloc] init];
        self->logLevel = 0;
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"Gyroscope"];
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
    if([self->_motionManager isGryoAvailable])
    {
        /* Start the accelerometer if it is not active already */
        if([self->_motionManager isGryoActive] == NO)
        {
            resolve(@YES);
        } else {
            reject(@"-1", @"Gyroscope is not active", nil);
        }
    }
    else
    {
        reject(@"-1", @"Gyroscope is not available", nil);
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
    double x = self->_motionManager.gyroData.rotationRate.x;
    double y = self->_motionManager.gyroData.rotationRate.y;
    double z = self->_motionManager.gyroData.rotationRate.z;

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
        NSLog(@"startUpdates/startGyroUpdates");
    }

    [self->_motionManager startDeviceMotionUpdates];

    /* Receive the gyroscope data on this block */
    [self->_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                               withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         double x = data.rotationRate.x;
         double y = data.rotationRate.y;
         double z = data.rotationRate.z;

         if (self->logLevel > 1) {
             NSLog(@"Updated gyro values: %f, %f, %f", x, y, z);
         }

         [self sendEventWithName:@"Gyroscope" body:@{
                                                                                     @"x" : [NSNumber numberWithDouble:x],
                                                                                     @"y" : [NSNumber numberWithDouble:y],
                                                                                     @"z" : [NSNumber numberWithDouble:z],
                                                                                 }];
     }];

}

RCT_EXPORT_METHOD(stopUpdates) {
    if (self->logLevel > 0) {
        NSLog(@"stopUpdates");
    }

    [self->_motionManager stopGyroUpdates];
}

@end
