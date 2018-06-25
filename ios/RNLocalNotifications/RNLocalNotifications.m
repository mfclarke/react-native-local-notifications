#import <UIKit/UIKit.h>
#import "RCTBridgeModule.h"


@interface RNLocalNotifications : NSObject <RCTBridgeModule>
@end

@implementation RNLocalNotifications

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(createNotification:(NSInteger *)id text:(NSString *)text datetime:(NSString *)datetime sound:(NSString *)sound hiddendata:(NSString *)hiddendata repeatInterval:(NSInteger)repeatInterval)
{
    [self createAlarm:id text:text datetime:datetime sound:sound update:FALSE hiddendata:(NSString *)hiddendata repeatInterval:repeatInterval];
};

RCT_EXPORT_METHOD(deleteNotification:(NSInteger *)id)
{
    [self deleteAlarm:id];
};

RCT_EXPORT_METHOD(updateNotification:(NSInteger *)id text:(NSString *)text datetime:(NSString *)datetime sound:(NSString *)sound hiddendata:(NSString *)hiddendata repeatInterval:(NSInteger)repeatInterval)
{
    [self createAlarm:id text:text datetime:datetime sound:sound update:TRUE hiddendata:(NSString *)hiddendata repeatInterval:repeatInterval];
};

RCT_EXPORT_METHOD(setAndroidIcons:(NSString *)largeIconName largeIconType:(NSString *)largeIconType smallIconName:(NSString *)smallIconName smallIconType:(NSString *)smallIconType)
{
    //Do nothing
};

- (void)createAlarm:(NSInteger)id text:(NSString *)text datetime:(NSString *)datetime sound:(NSString *)sound update:(Boolean *)update hiddendata:(NSString *)hiddendata repeatInterval:(NSInteger)repeatInterval {
    if(update){
        [self deleteAlarm:id];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *fireDate = [dateFormat dateFromString:datetime];
    if ([[NSDate date]compare: fireDate] == NSOrderedAscending) { //only schedule items in the future!
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = fireDate;
        if([sound isEqualToString:@"default"] && ![sound isEqualToString:@"silence"]){
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        else if([sound isEqualToString:@"silence"]){
            notification.soundName = @"silence.caf";
        }
        else {
            notification.soundName = [NSString stringWithFormat:@"%@.caf", sound];
        }
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = [self calendarUnitFromInterval: repeatInterval];
        notification.alertBody = text;
        notification.alertAction = @"Open";
        NSMutableDictionary *md = [[NSMutableDictionary alloc] init];
        [md setValue:[NSNumber numberWithInteger:id] forKey:@"id"];
        [md setValue:text forKey:@"text"];
        [md setValue:datetime forKey:@"datetime"];
        [md setValue:sound forKey:@"sound"];
        [md setValue:hiddendata forKey:@"hiddendata"];
        notification.userInfo = md;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
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

- (void)deleteAlarm:(NSInteger)id {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    for (UILocalNotification * notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSMutableDictionary *md = [notification userInfo];
        if ([[md valueForKey:@"id"] integerValue] == [[NSNumber numberWithInteger:id] integerValue]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

@end
