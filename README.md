# react-native-local-notifications
Manageable local notifications for React Native on iOS and Android. Create, update and delete local notifications by their unique id. The push notification title is the app name. When you open the app all displayed local notifications will be removed and the badge counter will be reset on iOS.

This is a fork of wumke/react-native-local-notifications to add support for repeating notifications, iOS permissions request and modern iOS integration. I plan to add support for persisting alarms so they are recreated on phone restart for Android, and add support for local geo-fence notifications in future.

NOTICE:
- for React Native < 0.47 use react-native-immediate-phone-call <1.x.x
- for React Native > 0.47 use react-native-immediate-phone-call >=1.x.x

## Setup

```bash
npm install react-native-local-notifications --save
react-native link react-native-local-notifications
```

#### iOS
* Add RNLocalNotifications.xcoderproj into your project in the Libraries folder.
* Add the .a file on the General tab of your target under Linked Frameworks And Libraries
* Add the .a file on the Build Phases tab of your target under Link Binary With Libraries
* In the AppDelegate.m file of your xcode project add above `@implementation AppDelegate`:
    ```
    @import UserNotifications;
    ```
* Above the line `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions` add:
    ```
    RNLocalNotifications *notificationCenterDelegate;
    ```
* In between the `rootView.backgroundColor` line and the `self.window = ` line add:
    ```
    notificationCenterDelegate = [[RNLocalNotifications alloc] init];
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:notificationCenterDelegate];
    ```
* Near the bottom of the file (before `@end`) add:
    ```
    - (void)applicationDidBecomeActive:(UIApplication *)application
    {
      [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; //Allways reset number of notifications shown at the icon
      [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    }
    ```
* Add Alarm.caf and Silence.caf to the Resources folder of your xcode project. (can be found in react-native-local-notifications/ios/RNLocalNotifications)

#### Android
* In the AndroidManifest.xml file of your android studio project add:
    ```
    <receiver android:process=":remote" android:name="com.github.wumke.RNLocalNotifications.AlarmReceiver" android:exported="true"></receiver>
    ```
* In the MainActivity.java file of your android studio project add:
  ```
  @Override
    public void onResume() {
        super.onResume();
        NotificationManager nMgr = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        nMgr.cancelAll();

        Intent intent = getIntent();
        String hiddendata = intent.getStringExtra("hiddendata");

        if (hiddendata != null) {
            ReactInstanceManager manager = getReactInstanceManager();
            ReactContext context = manager.getCurrentReactContext();

            WritableMap params = Arguments.createMap();
            params.putString("hiddendata", hiddendata);
            sendEvent(context, "AlertOpened", params);

            intent.removeExtra("hiddendata");
        }
    }
  ```
* In the settings.gradle
  ```
    include ':react-native-local-notifications', ':app'
    project(':react-native-local-notifications').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-local-notifications/android')
  ```
* In the build.gradle
  ```
    implementation project(':react-native-local-notifications')
  ```
* In MainApplication.java
  ```
    import com.github.wumke.RNLocalNotifications.RNLocalNotificationsPackage;
    ...
    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
        ...
        new RNLocalNotificationsPackage(),
        ...
      );
    }
    ...
  ```
## Usage

####Examples:
```javascript
import RNLocalNotifications from 'react-native-local-notifications';
...
//RNLocalNotifications.setAndroidIcons(largeIconName, largeIconType, smallIconName, smallIconType);
RNLocalNotifications.setAndroidIcons("ic_launcher", "mipmap", "notification_small", "drawable"); //this are the default values, this function is optional. But make sure these files exist otherwise your app will crash when the alarm fires.

//RNLocalNotifications.createNotification(id, text, datetime, sound[, hiddendata]);
RNLocalNotifications.createNotification(1, 'Some text', '2017-01-02 12:30', 'default', 'user_page', 4);

//RNLocalNotifications.updateNotification(id, text, datetime, sound[, hiddendata]);
RNLocalNotifications.updateNotification(1, 'Some modifications to text', '2017-01-02 12:35', 'silence', 'user_page', 4);

//RNLocalNotifications.deleteNotification(id);
RNLocalNotifications.deleteNotification(1);
...
```
#### Parameter explanation:
* id (Integer): Unique value to be able to edit or cancel scheduled notifications.
* text (String): The message text.
* datetime (String): The date + time to show the notification, as a string in the format 'yyyy-mm-dd hh:mm'.
* sound (String): Which sound is played: '' or 'silence' for vibration only, 'default' for system alarm sound, custom sound namefor self added ringtones.
* hiddendata (String): Invisible data that can be used to perform custom actions when the mobile app is opened by clicking on the local notification.
* interval (Integer): A number corresponding to the desired repeat interval.
    * 0: No repeat
    * 1: Every minute
    * 2: Every hour
    * 3: Every day
    * 4: Every week
    * 5: Every month (not calendar month but 30 days)
    * 6: Every year

#### Add custom sounds:

Convert your ringtone to .caf and .mp3 file formats.

__iOS__: Add yoursound.caf to the Resources folder of your xcode project.  
__Android__: Add yoursound.mp3 to the 'raw' folder

Use 'yoursound' as string for the sound parameter.

#### Hidden/extra data:

When you need to include custom, non-visible, data (for example object id's) to your notifications provide the optional 'hiddendata' parameter to createNotification/updateNotification.

The value will be available to React Native via an Event emitted when the notification is opened. You will need to listen for this with code like:

    ```
    const notificationsEventEmitter = new NativeEventEmitter(RNLocalNotifications)
    this.subscription = notificationsEventEmitter.addListener('AlertOpened', alert => {
      // hiddendata available as alert.hiddendata
    })
    ```

Note that 'hiddendata' must be a string, so if you want to include json objects you need to encode/decode the data yourself.

## Versioning

This project uses semantic versioning: MAJOR.MINOR.PATCH.
This means that releases within the same MAJOR version are always backwards compatible. For more info see [semver.org](http://semver.org/).

## Licence

MIT (see LICENCE file)

## Release notes

#### 2.0.0

Breaking changes
- create and updateNotification functions updated with new parameter
- iOS app integration totally changed  

New features / Updates
- Added repeating notifications
- Migrated iOS away from deprecated notifications API to iOS 10+ UserNotifications API
- Added request for permissions for iOS

Fixes
- Fixed notifications on iOS not working due to no permissions requested
- Note on supplying correct images for Android to work
