#import <UIKit/UIKit.h>
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
@import UserNotifications;

@interface RNLocalNotifications : RCTEventEmitter <RCTBridgeModule>
@end

@implementation RNLocalNotifications

bool hasListeners;

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(requestAuthorization,
                 requestAuthorizationWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (granted) {
      resolve(Nil);
    } else {
      reject(@"permission_rejected", @"User rejected notifications", error);
    }
  }];
}

RCT_EXPORT_METHOD(createNotification:(NSInteger)identifier text:(NSString *)text datetime:(NSString *)datetime sound:(NSString *)sound hiddendata:(NSString *)hiddendata repeatIntervalType:(NSInteger)repeatIntervalType)
{
    [self createAlarm:identifier text:text datetime:datetime sound:sound update:FALSE hiddendata:(NSString *)hiddendata repeatIntervalType:repeatIntervalType];
};

RCT_EXPORT_METHOD(deleteNotification:(NSInteger)identifier)
{
    [self deleteAlarm:identifier];
};

RCT_EXPORT_METHOD(updateNotification:(NSInteger)identifier text:(NSString *)text datetime:(NSString *)datetime sound:(NSString *)sound hiddendata:(NSString *)hiddendata repeatIntervalType:(NSInteger)repeatIntervalType)
{
    [self createAlarm:identifier text:text datetime:datetime sound:sound update:YES hiddendata:(NSString *)hiddendata repeatIntervalType:repeatIntervalType];
};

RCT_EXPORT_METHOD(setAndroidIcons:(NSString *)largeIconName largeIconType:(NSString *)largeIconType smallIconName:(NSString *)smallIconName smallIconType:(NSString *)smallIconType)
{
    //Do nothing
};

- (void)createAlarm:(NSInteger)identifier text:(NSString *)text datetime:(NSString *)datetime sound:(NSString *)sound update:(BOOL)update hiddendata:(NSString *)hiddendata repeatIntervalType:(NSInteger)repeatIntervalType {
  if(update){
      [self deleteAlarm:identifier];
  }
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
  NSDate *fireDate = [dateFormat dateFromString:datetime];
  if ([[NSDate date]compare: fireDate] == NSOrderedAscending) {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.body = text;
    if([sound isEqualToString:@"default"]){
      content.sound = [UNNotificationSound defaultSound];
    }
    else if([sound isEqualToString:@"silence"]){
      content.sound = [UNNotificationSound soundNamed:@"silence.caf"];
    }
    else {
      content.sound = [UNNotificationSound soundNamed:[NSString stringWithFormat:@"%@.caf", sound]];
    }
    content.sound = [UNNotificationSound defaultSound];
    NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
    [md setValue:[NSNumber numberWithInteger:identifier] forKey:@"id"];
    [md setValue:text forKey:@"text"];
    [md setValue:datetime forKey:@"datetime"];
    [md setValue:sound forKey:@"sound"];
    [md setValue:hiddendata forKey:@"hiddendata"];
    content.userInfo = md;
    
    NSDateComponents *comps = [self componentsFromIntervalType:repeatIntervalType forDate:fireDate];
    UNNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:comps repeats:(repeatIntervalType != 0)];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@(identifier).stringValue content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:nil];
  }
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

-(void)startObserving {
  hasListeners = YES;
}

-(void)stopObserving {
  hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"AlertOpened"];
}

- (void)alertOpenedWithHiddendata:(NSString *)hiddendata
{
  if (hasListeners) {
    [self sendEventWithName:@"AlertOpened" body:@{"hiddendata": hiddendata}];
  }
}

- (NSCalendarUnit)calendarUnitFromInterval:(NSInteger)interval {
  switch (interval) {
    case 0:
      return 0; // As per docs, 0 means don't repeat
    case 1:
      return NSCalendarUnitMinute;
    case 2:
      return NSCalendarUnitHour;
    case 3:
      return NSCalendarUnitDay;
    case 4:
      return NSCalendarUnitWeekOfYear;
    case 5:
      return NSCalendarUnitMonth;
    case 6:
      return NSCalendarUnitYear;
    default:
      return 0;
      break;
  }
}

- (NSDateComponents *)componentsFromIntervalType:(NSInteger)intervalType forDate:(NSDate *)date {
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  switch (intervalType) {
    case 0: // Don't repeat
      return [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    case 1:
      return [gregorian components:(NSCalendarUnitSecond) fromDate:date];
    case 2:
      return [gregorian components:(NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    case 3:
      return [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    case 4:
      return [gregorian components:(NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    case 5:
      return [gregorian components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    case 6:
      return [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    default:
      return 0;
      break;
  }
}

- (void)deleteAlarm:(NSInteger)identifier {
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  [center removePendingNotificationRequestsWithIdentifiers:@[@(identifier).stringValue]];
}

@end
