//
//  RNLocalNotifications.h
//  RNLocalNotifications
//
//  Created by Maximilian Clarke on 28/6/18.
//  Copyright © 2018 remobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
@import UserNotifications;

@interface RNLocalNotifications : RCTEventEmitter <UNUserNotificationCenterDelegate>
@end
